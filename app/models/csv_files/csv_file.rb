class CsvFile < ActiveRecord::Base
  attr_accessor :upload

  # Required for validation, and lists all allowed derived csv file tables.
  STI = { 
    'AccreditationCsvFile' => Accreditation,
    'ArfGibillCsvFile' => ArfGibill,
    'ComplaintCsvFile' => Complaint,
    'EightKeyCsvFile' => EightKey,
    'HcmCsvFile' => Hcm,
    'IpedsHdCsvFile' => IpedsHd,
    'IpedsIcCsvFile' => IpedsIc,
    'IpedsIcAyCsvFile' => IpedsIcAy,
    'IpedsIcPyCsvFile' => IpedsIcPy,
    'MouCsvFile' => Mou,
    'OutcomeCsvFile' => Outcome,
    'P911TfCsvFile' => P911Tf,
    'P911YrCsvFile' => P911Yr,
    'ScorecardCsvFile' => Scorecard,
    'Sec702CsvFile' => Sec702,
    'Sec702SchoolCsvFile' => Sec702School,
    'SettlementCsvFile' => Settlement,
    'SvaCsvFile' => Sva,
    'VaCrosswalkCsvFile' => VaCrosswalk,
    'VsocCsvFile' => Vsoc,
    'WeamsCsvFile' => Weam 
  }

  DELIMITERS = [',', '|', ' ']

  validates :type, inclusion: { in: STI.keys  }

  before_save :set_name, :upload_file, :populate
  before_destroy :clear_data

  #############################################################################
  ## last_upload_date
  ## Gets the date on which the last file was uploaded
  #############################################################################
  scope :last_upload_date, -> { 
    maximum(:upload_date).in_time_zone('Eastern Time (US & Canada)') 
  }

  #############################################################################
  ## last_upload
  ## Gets the last uploaded csv.
  #############################################################################
  scope :last_upload, -> { order(:upload_date, :id).last }

  #############################################################################
  ## inherited
  ## Patch for ActionPack in url generating methods that use AR instances.
  ## For example, form_for @some_record. This method overrides the model_name
  ## method for subclasses to return the base class (CsvFile) name so that
  ## only one controller is required to handle all STI, so that form_for, 
  ## link_to, and so on all refer tho the RawFile controller, regardless of 
  ## subtype ... (mph)
  #############################################################################
  def self.inherited(child)
    child.instance_eval do
      def model_name
        CsvFile.model_name
      end
    end

    super 
  end

  #############################################################################
  ## types
  ## Creates a collection for every defined subtype (WeamsCsvile, 
  ## CrosswalkCsvFile, ...). However, this (and for other reasons) require 
  ## that STI subclasses are preloaded in the development environment rather 
  ## than lazy loaded. A Parent class is not aware of a child until that child 
  ## is loaded. (mph)
  ##
  ## c.f. /config/initializers/preload_sti_models.rb
  #############################################################################
  def self.types
    descendants.map do |csv| 
      [csv.to_s.underscore.split('_').map(&:capitalize).join(' '), csv.to_s] 
    end
  end

  #############################################################################
  ## class_to_type
  ## Converts the class name into the name its corresponding file file type.
  #############################################################################
  def class_to_type
    self.class.name.underscore
  end

  #############################################################################
  ## clear_data
  #############################################################################
  def clear_data
    if latest?
      if store = CsvStorage.find_by(csv_file_type: type)
        store.data_store = nil
        store.save!
      end

      STI[type].delete_all
    end
  end

  #############################################################################
  ## set_name
  ## Builds the name of the raw file on the server by combining the timestamp
  ## and csv file type name. If there is not associated csv data storage,
  ## storage for the csv type is created.
  #############################################################################
  def set_name
    self.upload_date = DateTime.current

    self.name = upload_date.strftime("%y%m%d%H%M%S%L")
    self.name += "_#{class_to_type}.csv"
  end

  #############################################################################
  ## upload_file
  ## Uploads the given file into the storage data binary.
  #############################################################################  
  def upload_file
    store = CsvStorage.find_or_create_by(csv_file_type: type)

    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    begin
      # Require an upload file, doesn't make sense to allow updates without.
      raise StandardError.new("No upload file provided.") if upload.blank?

      store.data_store = upload.read
      rc = store.save 
    rescue StandardError => e
      errors[:base] << e.message
      rc = false
    ensure
      ActiveRecord::Base.logger = old_logger      
    end

    return rc
  end

  #############################################################################
  ## clean_line
  ## Removes nasty non utf binary stuff.
  #############################################################################
  def clean_line(l)
    l.try(:encode, "UTF-8", "ascii-8bit", invalid: :replace, undef: :replace)
      .try(:chop)
  end

  #############################################################################
  ## get_headers
  ## Interprets the current line as a string containing csv headers.
  #############################################################################
  def get_headers(header_line)
    headers = CSV.parse_line(header_line, col_sep: delimiter).map do |header|
      header.try(:strip).try(:downcase)
    end

    header_map = self.class::HEADER_MAP

    # Headers must contain at least the HEADER_MAP. Subtracting Array A from
    # B = all elements in A not in B. This should be empty.
    missing_headers = header_map.keys - headers
    if (missing_headers).present?
      raise StandardError.new("Missing headers in #{name}: #{missing_headers.inspect}") 
    end

    headers
  end

  #############################################################################
  ## get_row
  ## Interprets the current line as a csv row, and returns those values
  ## corresponding to the header rows we use.
  #############################################################################
  def get_row(line, headers)
    values = CSV.parse_line(line, col_sep: delimiter)

    # Grab these constants from the derived tables.
    header_map = self.class::HEADER_MAP
    disallowed_chars = self.class::DISALLOWED_CHARS

     # Map the header indexes to the values we need
    header_map.keys.inject({}) do |hash, header|
      i = headers.find_index(header)

      key = header_map[header]

      # Get the value, strip out bad chars, and normalize common values
      hash[key] = (values[i] || "").gsub(disallowed_chars, "").strip
      hash
    end
  end

  #############################################################################
  ## write_data
  ## Reads the associated csv data store and writes those lines to the 
  ## intermediate csv file in preparation for building the database.
  #############################################################################
  def write_data
    table = STI[self.class.name]
    table.delete_all

    lines = CsvStorage.find_by!(csv_file_type: self.class.name).data_store.lines
    lines.shift(self.class::SKIP_LINES_BEFORE_HEADER)

    headers = get_headers(clean_line(lines.shift))
    lines.shift(self.class::SKIP_LINES_AFTER_HEADER)

    ActiveRecord::Base.transaction do
      lines.each do |line|
        line = clean_line(line) || ""
        row = get_row(line, headers)

        # Allow a block, if given to determine if row is created
        unless row.values.join.blank?
          table.create!(row) if !block_given? || yield(row)
        end
      end
    end
  end

  #############################################################################
  ## latest?
  ## True if this instance is the last uploaded for its type.
  #############################################################################
  def latest?
    str1 = upload_date.strftime("%y%m%d%H%M%S%6N")
    str2 = self.class.last_upload_date.strftime("%y%m%d%H%M%S%6N")
    str1 == str2
  end

  #############################################################################
  ## humanize_date
  ## Returns a readable form of the upload date.
  #############################################################################
  def humanize_date
    upload_date.present? ? upload_date.strftime("%B %d, %Y") : '-'
  end

  #############################################################################
  ## humanize_type
  ## Returns a readable form of the class type.
  #############################################################################
  def humanize_type
    class_to_type.split("_").map(&:capitalize).join(" ")
  end
end

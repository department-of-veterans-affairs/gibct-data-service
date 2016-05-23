class EightKeyCsvFile < CsvFile
  HEADER_MAP = {
    "institution of higher education" => :institution,
    "opeid" => :ope,
    "ipeds id" => :cross
  }

  SKIP_LINES_BEFORE_HEADER = 1
  SKIP_LINES_AFTER_HEADER = 0

  DISALLOWED_CHARS = /[^#\dA-Za-z \-\.]/

  #############################################################################
  ## populate
  ## Reloads the accreditation table with the data in the csv data store
  #############################################################################  
  def populate
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    begin
      # Write only if the row does not contain the state name only
      write_data do |row|
        !DS::State.get_full_names.map(&:downcase)
          .include?(row[:institution].try(:downcase))
      end
 
      rc = true
    rescue StandardError => e
      errors[:base] << e.message
      rc = false
    ensure
      ActiveRecord::Base.logger = old_logger    
    end

    return rc
  end
end
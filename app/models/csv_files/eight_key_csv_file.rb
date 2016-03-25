require "csv"

class EightKeyCsvFile < CsvFile
  HEADER_MAP = {
    "institution of higher education" => :institution,
    "city" => :city,
    "state" => :state,
    "opeid" => :ope,
    "ipeds id" => :cross,
    "notes" => :notes
  }

  SKIP_LINES_BEFORE_HEADER = 1
  SKIP_LINES_AFTER_HEADER = 0

  NORMALIZE = {
    ope: ->(ope) do 
      ope.present? && ope.downcase != 'none' ? ope.rjust(8, "0") : ""
    end,

    cross: ->(cross) do 
      cross.present? && cross.downcase != 'none' ? cross.rjust(6, "0") : ""
    end
  }

  DISALLOWED_CHARS = /[^\w@\- \.\/]/

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
        !DS_ENUM::State.get_full_names.map(&:downcase)
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
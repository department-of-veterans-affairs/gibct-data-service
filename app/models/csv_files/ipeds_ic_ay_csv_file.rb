require "csv"

class IpedsIcAyCsvFile < CsvFile
  HEADER_MAP = {
    "unitid" => :cross,
    "chg2ay3" => :chg2ay3,
    "chg3ay3" => :chg3ay3,
    "chg4ay3" => :chg4ay3
  }

  SKIP_LINES_BEFORE_HEADER = 0
  SKIP_LINES_AFTER_HEADER = 0

  NORMALIZE = {
    cross: ->(cross) do 
      cross.present? && cross.downcase != 'none' ? cross.rjust(8, "0") : ""
    end
  }

  DISALLOWED_CHARS = /[^\w@\- \/]/

  #############################################################################
  ## populate
  ## Reloads the accreditation table with the data in the csv data store
  #############################################################################  
  def populate
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    begin
      write_data 
 
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
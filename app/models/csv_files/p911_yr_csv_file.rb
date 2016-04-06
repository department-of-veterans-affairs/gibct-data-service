require "csv"

class P911YrCsvFile < CsvFile
  HEADER_MAP = {
    "facility code" => :facility_code,
    "name of institution" => :institution,
    "number of trainees" => :p911_yr_recipients,
    "total cost" => :p911_yellow_ribbon
  }

  SKIP_LINES_BEFORE_HEADER = 0
  SKIP_LINES_AFTER_HEADER = 1

  DISALLOWED_CHARS = /[^\dA-Za-z \-\.]/

  #############################################################################
  ## populate
  ## Reloads the accreditation table with the data in the csv data store
  #############################################################################  
  def populate
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    begin
      # Write only if the row does not contain the state name only
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
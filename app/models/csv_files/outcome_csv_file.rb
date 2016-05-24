class OutcomeCsvFile < CsvFile
  HEADER_MAP = {
    "va_facility_code" => :facility_code,
    "va_facility_name" => :institution,
    "retention_rate_veteran_ba" => :retention_rate_veteran_ba,
    "retention_rate_veteran_otb" => :retention_rate_veteran_otb,
    "persistance_rate_veteran_ba" => :persistance_rate_veteran_ba,
    "persistance_rate_veteran_otb" => :persistance_rate_veteran_otb,
    "graduation_rate_veteran" => :graduation_rate_veteran,
    "transfer_out_rate_veteran" => :transfer_out_rate_veteran
  }

  SKIP_LINES_BEFORE_HEADER = 0
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
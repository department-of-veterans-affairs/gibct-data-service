class AccreditationCsvFile < CsvFile
  HEADER_MAP = {
    "institution_name" => :institution_name,
    "institution_opeid" => :ope,
    "institution_ipeds_unitid" => :institution_ipeds_unitid,
    "campus_name" => :campus_name,
    "campus_ipeds_unitid" => :campus_ipeds_unitid,
    "accreditation_type" => :csv_accreditation_type,
    "agency_name" => :agency_name,
    "last action" => :accreditation_status,
    "periods" => :periods
  }

  SKIP_LINES_BEFORE_HEADER = 0
  SKIP_LINES_AFTER_HEADER = 0

  DISALLOWED_CHARS = /[^#&'@:=\w\- \.\/\(\)]/

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
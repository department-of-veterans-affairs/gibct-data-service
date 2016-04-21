class IpedsIcCsvFile < CsvFile
  HEADER_MAP = {
    "unitid" => :cross,
    "vet2" => :vet2,
    "vet3" => :vet3,
    "vet4" => :vet4,
    "vet5" => :vet5,
    "calsys" => :calsys,
    "distnced" => :distnced
  }

  SKIP_LINES_BEFORE_HEADER = 0
  SKIP_LINES_AFTER_HEADER = 0

  DISALLOWED_CHARS = /[^\w@\- \.\/]/

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
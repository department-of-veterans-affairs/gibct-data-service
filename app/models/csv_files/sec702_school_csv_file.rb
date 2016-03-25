require "csv"

class Sec702SchoolCsvFile < CsvFile
  HEADER_MAP = {
    "facility code" => :facility_code,
    "section_702" => :sec_702
  }

  SKIP_LINES_BEFORE_HEADER = 0
  SKIP_LINES_AFTER_HEADER = 0

  NORMALIZE = {
    sec_702: ->(sec_702) do 
      sec_702 = 'Yes' if sec_702 =='Ye' 
      DS_ENUM::Truth.value_to_truth(sec_702) if sec_702.present? 
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
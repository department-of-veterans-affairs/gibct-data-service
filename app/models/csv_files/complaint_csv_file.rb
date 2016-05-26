class ComplaintCsvFile < CsvFile
  HEADER_MAP = {
    "status" => :status,
    "school" => :institution,
    "opeid" => :ope,
    "facility code" => :facility_code,
    "closed reason" => :closed_reason,
    "issues" => :issue
  }

  SKIP_LINES_BEFORE_HEADER = 7
  SKIP_LINES_AFTER_HEADER = 0

  DISALLOWED_CHARS = /[^#\w@\- \.\/]/

  #############################################################################
  ## populate
  ## Reloads the accreditation table with the data in the csv data store
  #############################################################################  
  def populate
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    begin
      # OPE ids are unreliable, but we set them later with the crosswalk, so
      # just remove them for now.
      write_data do |row|
        row[:ope] = nil
        true
      end

      Complaint.update_sums_by_fac
      ## MPH move these into data_csv build
      # Complaint.update_sums_by_ope6
 
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
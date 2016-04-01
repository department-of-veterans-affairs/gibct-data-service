require "csv"

class SvaCsvFile < CsvFile
  HEADER_MAP = {
    "school" => :institution,
    "ipeds_6" => :cross,
    "city" => :city,
    "state" => :state,
    "website" => :student_veteran_link
  }

  SKIP_LINES_BEFORE_HEADER = 0
  SKIP_LINES_AFTER_HEADER = 0

  NORMALIZE = {
    cross: ->(cross) do 
      cross.present? && cross.downcase != 'none' ? cross.rjust(8, "0") : ""
    end,
    
    state: ->(state) { state.length != 2 ? DS::State[state] : state.upcase }
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
require "csv"

class VaCrosswalkCsvFile < CsvFile
  HEADER_MAP = {
    "facility code" => :facility_code,
    "institution name" => :institution,
    "city" => :city,
    "state" => :state,
    "ipeds" => :cross,
    "ope" => :ope,
    "notes" => :notes
  }

  SKIP_LINES_BEFORE_HEADER = 0
  SKIP_LINES_AFTER_HEADER = 0

  NORMALIZE = {
    ope: ->(ope) do 
      ope.present? && ope.downcase != 'none' ? ope.rjust(8, "0") : ""
    end,

    cross: ->(cross) do 
      cross.present? && cross.downcase != 'none' ? cross.rjust(8, "0") : ""
    end,

    state: ->(state) { state.length != 2 ? DS_ENUM::State[state] : state.upcase }
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
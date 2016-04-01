require "csv"

class MouCsvFile < CsvFile
  HEADER_MAP = {
    "institution name" => :institution,
    "city" => :city,
    "state" => :state,
    "ope id" => :ope,
    "status" => :dod_mou
  }

  SKIP_LINES_BEFORE_HEADER = 1
  SKIP_LINES_AFTER_HEADER = 0

  NORMALIZE = {
    ope: ->(ope) do 
      ope.present? && ope.downcase != 'none' ? ope.rjust(8, "0") : ""
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
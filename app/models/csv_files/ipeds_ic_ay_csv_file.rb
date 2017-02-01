class IpedsIcAyCsvFile < CsvFile
  HEADER_MAP = {
    'unitid' => :cross,
    'chg2ay3' => :tuition_in_state,
    'chg3ay3' => :tuition_out_of_state,
    'chg4ay3' => :books
  }.freeze

  SKIP_LINES_BEFORE_HEADER = 0
  SKIP_LINES_AFTER_HEADER = 0

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

    rc
  end
end

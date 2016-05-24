class WeamsCsvFile < CsvFile
	HEADER_MAP = {
		"facility code" => :facility_code,
		"institution name" => :institution,
		"institution city" => :city,
		"institution state" => :state,
		"institution zip code" => :zip,
		"institution country" => :country,
		"accredited" => :accredited,
		"current academic year bah rate" => :bah,
		"principles of excellence" => :poe,
		"current academic year yellow ribbon" => :yr,
    "poo status" => :poo_status,
    "applicable law code" => :applicable_law_code,
    "institution of higher learning indicator" => :institution_of_higher_learning_indicator,
		"ojt indicator" => :ojt_indicator,
		"correspondence indicator" => :correspondence_indicator,
		"flight indicator" => :flight_indicator,
    "non-college degree indicator" => :non_college_degree_indicator
	}

  SKIP_LINES_BEFORE_HEADER = 0
  SKIP_LINES_AFTER_HEADER = 1

  DISALLOWED_CHARS = /[^#\w@\- \.\/]/

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
      self.errors[:base] << e.message
      rc = false
    ensure
      ActiveRecord::Base.logger = old_logger    
    end

    return rc
  end
end
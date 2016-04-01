require "csv"

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
  SKIP_LINES_AFTER_HEADER = 0

  # Kludge for csv.parse omitting last character of line at EOF
  NORMALIZE = {
    poe: ->(poe) do 
      DS::Truth.value_to_truth(poe) if poe.present? 
    end,

    yr: ->(yr) do 
      DS::Truth.value_to_truth(yr) if yr.present? 
    end,

    institution_of_higher_learning_indicator: ->(institution_of_higher_learning_indicator) do 
      DS::Truth.value_to_truth(institution_of_higher_learning_indicator) if institution_of_higher_learning_indicator.present? 
    end,

    ojt_indicator: ->(ojt_indicator) do 
      DS::Truth.value_to_truth(ojt_indicator) if ojt_indicator.present? 
    end,

    correspondence_indicator: ->(correspondence_indicator) do 
      DS::Truth.value_to_truth(correspondence_indicator) if correspondence_indicator.present? 
    end,

    flight_indicator: ->(flight_indicator) do 
      DS::Truth.value_to_truth(flight_indicator) if flight_indicator.present? 
    end,

    non_college_degree_indicator: ->(non_college_degree_indicator) do 
      DS::Truth.value_to_truth(non_college_degree_indicator) if non_college_degree_indicator.present? 
    end,

    accredited: ->(accredited) do 
      accredited = 'Yes' if accredited == 'Ye'
      DS::Truth.value_to_truth(accredited) if accredited.present? 
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
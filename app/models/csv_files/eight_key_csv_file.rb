require "csv"

class EightKeyCsvFile < CsvFile
  HEADER_MAP = {
    "Institution of Higher Education" => :institution,
    "City" => :city,
    "State" => :state,
    "OPEID" => :ope,
    "IPEDS ID" => :cross,
    "Notes" => :notes
  }

  #############################################################################
  ## populate
  ## Reloads the eight keys table with the data in the csv data store
  #############################################################################  
  def populate
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    # TODO: Remove Kludgy fix for state rows that group states in eight-keys.csv
    states = [
      "alaska", "alabama", "arkansas", "american samoa", "arizona", "california", 
      "colorado", "connecticut", "district of columbia", "delaware", "florida", 
      "georgia", "guam", "hawaii", "iowa", "idaho", "illinois", "indiana", 
      "kansas", "kentucky", "louisiana", "massachusetts", "maryland", "maine", 
      "michigan", "minnesota", "missouri", "northern mariana islands", 
      "mississippi", "montana", "north carolina", "north dakota", "nebraska", 
      "new hampshire", "new jersey", "new mexico", "nevada", "new york", 
      "ohio", "oklahoma", "oregon", "pennsylvania", "puerto rico", 
      "rhode island", "south carolina", "south dakota", "tennessee", "texas", 
      "united states minor outlying islands", "utah", "virginia", 
      "virgin islands", "vermont", "washington", "wisconsin", "west virginia", 
      "wyoming", "armed forces americas (except canada)", 
      "armed forces africa, canada, europe, middle east", 
      "armed forces pacific"
    ]

    begin
      store = CsvStorage.find_by!(csv_file_type: "EightKeyCsvFile")
      lines = store.data_store.lines.map(&:strip).reject(&:blank?)

      # Get rid of the first line it contains garbage.
      lines.shift

      headers = CSV.parse_line(lines.shift, col_sep: delimiter).map do |header|
        header.try(:strip)
      end

      # Headers must contain at least the HEADER_MAP. Subtracting Array A from
      # B = all elements in A not in B. This should be empty.
      missing_headers = HEADER_MAP.keys - headers
      if (missing_headers).present?
        raise StandardError.new("Missing headers in #{name}: #{missing_headers.inspect}") 
      end

      EightKey.destroy_all

      lines.each do |line|
        @myline = line
        @values = CSV.parse_line(line, col_sep: delimiter)
        @row = HEADER_MAP.keys.inject({}) do |hash, header|
          idx = headers.find_index(header)
          if @values[idx].present?
            hash[HEADER_MAP[header]] = @values[idx].encode("UTF-8", "ascii-8bit", invalid: :replace, undef: :replace)
          else
            hash[HEADER_MAP[header]] = ""
          end
          
          hash
        end

        # TODO: Remove Kludgy fix for state rows that group states
        unless states.include?(@row[:institution].try(:downcase))
          EightKey.create!(@row) 
        end
      end

      rc = true
    rescue StandardError => e
      errors[:base] << e.message
      errors[:base] << @row if @row
      rc = false
    ensure
      ActiveRecord::Base.logger = old_logger    
    end

    return rc
  end
end
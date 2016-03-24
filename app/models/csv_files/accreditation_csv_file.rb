class AccreditationCsvFile < CsvFile
  HEADER_MAP = {
    "Institution_Name" => :institution_name,
    "Institution_OPEID" => :ope,
    "Institution_IPEDS_UnitID" => :institution_ipeds_unitid,
    "Campus_Name" => :campus_name,
    "Campus_IPEDS_UnitID" => :campus_ipeds_unitid,
    "Accreditation_Type" => :csv_accreditation_type,
    "Agency_Name" => :agency_name,
    "Last Action" => :last_action,
    "Periods" => :periods
  }

  #############################################################################
  ## populate
  ## Reloads the accreditation table with the data in the csv data store
  #############################################################################  
  def populate
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    begin
      store = CsvStorage.find_by!(csv_file_type: "AccreditationCsvFile")
      lines = store.data_store.lines.map(&:strip).reject(&:blank?)

      headers = CSV.parse_line(lines.shift, col_sep: delimiter).map do |header|
        header.try(:strip)
      end

      # Headers must contain at least the HEADER_MAP. Subtracting Array A from
      # B = all elements in A not in B. This should be empty.
      missing_headers = HEADER_MAP.keys - headers
      if (missing_headers).present?
        raise StandardError.new("Missing headers in #{name}: #{missing_headers.inspect}") 
      end

      Accreditation.destroy_all

      lines.each do |line|
        @myline = line
        @values = CSV.parse_line(line, col_sep: delimiter)
        @row = HEADER_MAP.keys.inject({}) do |hash, header|
          idx = headers.find_index(header)
          value = @values[idx]

          if value.present?
            value = @values[idx].gsub('"', "") 
            hash[HEADER_MAP[header]] = value.encode("UTF-8", "ascii-8bit", invalid: :replace, undef: :replace)
          else
            hash[HEADER_MAP[header]] = ""
          end
          
          hash
        end

        Accreditation.create!(@row) unless @row.values.join.blank?
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
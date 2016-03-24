require "csv"

class ArfGibillCsvFile < CsvFile
  HEADER_MAP = {
    "FACILITY CODE" => :facility_code,
    "SCHOOL NAME" => :institution,
    "TOTAL COUNT OF STUDENTS" => :total_count_of_students
  }

  #############################################################################
  ## populate
  ## Reloads the arf_gibills table with the data in the csv data store
  #############################################################################  
  def populate
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    begin
      store = CsvStorage.find_by!(csv_file_type: "ArfGibillCsvFile")
      lines = store.data_store.lines.map(&:strip).reject(&:blank?)

      # Headers must contain at least the HEADER_MAP. Subtracting Array A from
      # B = all elements in A not in B. This should be empty.
      headers = CSV.parse_line(lines.shift, col_sep: delimiter).map do |header|
        header.try(:strip)
      end

      if (HEADER_MAP.keys - headers).present?
        raise StandardError.new("Missing headers in #{name}") 
      end

      ArfGibill.destroy_all

      lines.each do |line|
        values = CSV.parse_line(line, col_sep: delimiter)
        @row = HEADER_MAP.keys.inject({}) do |hash, header|
          idx = headers.find_index(header)
          if values[idx].present?
            hash[HEADER_MAP[header]] = values[idx].encode("UTF-8", "ascii-8bit", invalid: :replace, undef: :replace)
          else
            hash[HEADER_MAP[header]] = ""
          end
          
          hash
        end

        ArfGibill.create!(@row) unless @row.values.join.blank?
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
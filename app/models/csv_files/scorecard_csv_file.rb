require "csv"

class ScorecardCsvFile < CsvFile
  HEADER_MAP = {
    "UNITID" => :cross,
    "OPEID" => :ope,
    "INSTNM" => :institution,
    "INSTURL" => :insturl,
    "PREDDEG" => :pred_degree_awarded,
    "LOCALE" => :locale,
    "UGDS" => :undergrad_enrollment,
    "RET_FT4" => :retention_all_students_ba,
    "RET_FTL4" => :retention_all_students_otb,
    "md_earn_wne_p10" => :salary_all_students,
    "RPY_3YR_RT_SUPP" => :repayment_rate_all_students,
    "GRAD_DEBT_MDN_SUPP" => :avg_stu_loan_debt,
    "C150_4_POOLED_SUPP" => :c150_4_pooled_supp,
    "C200_L4_POOLED_SUPP" => :c200_l4_pooled_supp,
  }

  #############################################################################
  ## populate
  ## Reloads the weams table with the data in the csv data store
  #############################################################################  
  def populate
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    begin
      store = CsvStorage.find_by!(csv_file_type: "ScorecardCsvFile")
      lines = store.data_store.lines.map(&:strip).reject(&:blank?)

      # Headers must contain at least the HEADER_MAP. Subtracting Array A from
      # B = all elements in A not in B. This should be empty.
      headers = CSV.parse_line(lines.shift, col_sep: delimiter).map do |header|
        header.try(:strip)
      end

      missing_headers = HEADER_MAP.keys - headers
      if (missing_headers).present?
        raise StandardError.new("Missing headers in #{name}: #{missing_headers.inspect}") 
      end

      Scorecard.destroy_all

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

        Scorecard.create!(@row)
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

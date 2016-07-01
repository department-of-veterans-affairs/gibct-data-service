class ScorecardCsvFile < CsvFile
  HEADER_MAP = {
    "unitid" => :cross,
    "opeid" => :ope,
    "instnm" => :institution,
    "insturl" => :insturl,
    "preddeg" => :pred_degree_awarded,
    "locale" => :locale,
    "ugds" => :undergrad_enrollment,
    "ret_ft4" => :retention_all_students_ba,
    "ret_ftl4" => :retention_all_students_otb,
    "md_earn_wne_p10" => :salary_all_students,
    "rpy_3yr_rt_supp" => :repayment_rate_all_students,
    "grad_debt_mdn_supp" => :avg_stu_loan_debt,
    "c150_4_pooled_supp" => :c150_4_pooled_supp,
    "c200_l4_pooled_supp" => :c200_l4_pooled_supp,
  }

  SKIP_LINES_BEFORE_HEADER = 0
  SKIP_LINES_AFTER_HEADER = 0
  
  DISALLOWED_CHARS = /[^#%&'@:=\w\- \.\/\(\)\+\?]/

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

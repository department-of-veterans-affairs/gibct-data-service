require 'csv'

class DataCsv < ActiveRecord::Base
  # GIBCT uses field called type, must kludge to prevent STI
  self.inheritance_column = "inheritance_type"

  validates :facility_code, presence: true, uniqueness: true
  validates :institution, presence: true

  validates :state, inclusion: { in: DS::State.get_names }, allow_blank: true

  ###########################################################################
  ## complete?
  ## Returns true only if all data_stores are populated in CsvStorage.
  ###########################################################################
  def self.complete?
    CsvFile::STI.keys.inject(true) do |s,a| 
      store = CsvStorage.find_by(csv_file_type: a)
      s = s && store.present? && store.data_store.present?
    end
  end  

  ###########################################################################
  ## run_bulk_query
  ## Runs bulk query and provides support for created_at, updated_at, and
  ## renumbering autoincrements.
  ###########################################################################
  def self.run_bulk_query(query, create = false, restart = false)
    str = restart ? "ALTER SEQUENCE data_csvs_id_seq RESTART WITH 1; " : ""

    str += "ALTER TABLE data_csvs ALTER COLUMN updated_at SET DEFAULT now(); "
    str += query + ";"
    str += "ALTER TABLE data_csvs ALTER COLUMN updated_at DROP DEFAULT; "

    if create
      str = "ALTER TABLE data_csvs ALTER COLUMN created_at SET DEFAULT now(); " + str
      str += " ALTER TABLE data_csvs ALTER COLUMN created_at DROP DEFAULT; "
    end

    ActiveRecord::Base.connection.execute(str)
  end

  ###########################################################################
  ## build_data_csv
  ## Builds the data_csv table.
  ###########################################################################
  def self.build_data_csv
    return if !complete?

    initialize_with_weams
    update_with_crosswalk
    update_with_sva
    update_with_vsoc
    update_with_eight_key
    update_with_accreditation
    update_with_arf_gibill
    update_with_p911_tf
    update_with_p911_yr
    update_with_mou
    update_with_scorecard
    update_with_ipeds_ic
    update_with_ipeds_hd
    update_with_ipeds_ic_ay
    update_with_ipeds_ic_py
    update_with_sec702_school
    update_with_sec702
    update_with_settlement
    update_with_hcm
    update_with_complaint
    update_with_outcome
  end

  ###########################################################################
  ## to_csv
  ## Converts all the entries in the DataCsv to a csv string.
  ###########################################################################
  def self.to_csv
    CSV.generate do |csv|

      # Need to build csv in specific order for VA-EDU Dashboards
      cols = %W(
        facility_code institution city state zip country type correspondence 
        flight bah cross ope insturl vet_tuition_policy_url pred_degree_awarded 
        locale gibill undergrad_enrollment yr student_veteran student_veteran_link 
        poe eight_keys dodmou sec_702 vetsuccess_name vetsuccess_email 
        credit_for_mil_training vet_poc student_vet_grp_ipeds 
        soc_member va_highest_degree_offered retention_rate_veteran_ba 
        retention_all_students_ba retention_rate_veteran_otb
        retention_all_students_otb persistance_rate_veteran_ba 
        persistance_rate_veteran_otb graduation_rate_veteran 
        graduation_rate_all_students transfer_out_rate_veteran 
        transfer_out_rate_all_students salary_all_students 
        repayment_rate_all_students avg_stu_loan_debt calendar 
        tuition_in_state tuition_out_of_state books online_all 
        p911_tuition_fees p911_recipients p911_yellow_ribbon
        p911_yr_recipients accredited accreditation_type accreditation_status 
        caution_flag caution_flag_reason complaints_facility_code 
        complaints_financial_by_fac_code complaints_quality_by_fac_code 
        complaints_refund_by_fac_code complaints_marketing_by_fac_code
        complaints_accreditation_by_fac_code complaints_degree_requirements_by_fac_code
        complaints_student_loans_by_fac_code complaints_grades_by_fac_code
        complaints_credit_transfer_by_fac_code complaints_job_by_fac_code
        complaints_transcript_by_fac_code complaints_other_by_fac_code
        complaints_main_campus_roll_up complaints_financial_by_ope_id_do_not_sum
        complaints_quality_by_ope_id_do_not_sum complaints_refund_by_ope_id_do_not_sum
        complaints_marketing_by_ope_id_do_not_sum complaints_accreditation_by_ope_id_do_not_sum
        complaints_degree_requirements_by_ope_id_do_not_sum complaints_student_loans_by_ope_id_do_not_sum
        complaints_grades_by_ope_id_do_not_sum complaints_credit_transfer_by_ope_id_do_not_sum
        complaints_jobs_by_ope_id_do_not_sum complaints_transcript_by_ope_id_do_not_sum
        complaints_other_by_ope_id_do_not_sum
      )
      
      csv << cols

      all.order(:institution).each do |data|
        csv << data.attributes.values_at(*cols).map { |v| v == false ? '' : v }
      end
    end
  end

  ###########################################################################
  ## to_gibct
  ## Transfers data_csv entries to the GIBCT
  ###########################################################################
  def self.to_gibct(config = "./config/gibct_staging_database.yml")
    GibctInstitutionType.set_connection(config)
    GibctInstitution.set_connection(config)

    GibctInstitutionType.delete_all
    GibctInstitution.delete_all

    rows = DataCsv.all 

    types = rows.pluck(:type).uniq.inject({}) do |memo, type| 
      memo[type] = GibctInstitutionType.create(name: type).id
      memo
    end

    # Keep only those columns we want to transfer
    columns = GibctInstitution.column_names - %W(id created_at updated_at)

    rows = rows.map do |row|
      row = row.attributes

      row["ope"] = row["ope6"]
      row["institution_type_id"] = types[row["type"]]
      row.delete("type")

      columns.map do |column| 
        case GibctInstitution.columns_hash[column].type
        when :float, :integer
          row[column] || 0
        when :string, :datetime
          row[column].present? ? "'#{row[column]}'" : 'NULL'
        else
          row[column].nil? ? 'NULL' : row[column]
        end
      end.join(",")
    end

    if rows.length > 0
      str = "ALTER SEQUENCE institutions_id_seq RESTART WITH 1; "
      str += "ALTER TABLE institutions ALTER COLUMN created_at SET DEFAULT now(); "
      str += "ALTER TABLE institutions ALTER COLUMN updated_at SET DEFAULT now(); "
      str += "INSERT INTO institutions (" + columns.map { |c| %("#{c}") }.join(",") + ") "
      str += "VALUES " + rows.map { |row| "(#{row})" }.join(",")
      str += "; ALTER TABLE institutions ALTER COLUMN updated_at DROP DEFAULT; "
      str += "ALTER TABLE institutions ALTER COLUMN created_at DROP DEFAULT; "

      GibctInstitution.connection.execute(str)
    end

    GibctInstitution.remove_connection
    GibctInstitutionType.remove_connection
  end

  ###########################################################################
  ## initialize_with_weams
  ## Initializes the DataCsv table with data from approved weams schools.
  ###########################################################################
  def self.initialize_with_weams
    DataCsv.delete_all

    names = Weam::USE_COLUMNS.map(&:to_s).join(', ')

    query_str = "INSERT INTO data_csvs (#{names}) ("
    query_str += Weam.select(names).where(approved: true).to_sql + ")"    

    run_bulk_query(query_str, true, true)
  end

  ###########################################################################
  ## update_with_crosswalk
  ## Updates the DataCsv table with data from the crosswalk.
  ###########################################################################
  def self.update_with_crosswalk
    names = VaCrosswalk::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = va_crosswalks.#{name}) }.join(', ')
    query_str += ' FROM va_crosswalks '
    query_str += 'WHERE data_csvs.facility_code = va_crosswalks.facility_code'    

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_sva
  ## Updates the DataCsv table with data from the sva table.
  ###########################################################################
  def self.update_with_sva
    names = Sva::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += "student_veteran = TRUE, "
    query_str += names.map { |name| %("#{name}" = svas.#{name}) }.join(', ')
    query_str += ' FROM svas '
    query_str += 'WHERE data_csvs.cross = svas.cross '
    query_str += 'AND svas.cross IS NOT NULL'    

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_vsoc
  ## Updates the DataCsv table with data from the vsoc table.
  ###########################################################################
  def self.update_with_vsoc
    names = Vsoc::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = vsocs.#{name}) }.join(', ')
    query_str += ' FROM vsocs '
    query_str += 'WHERE data_csvs.facility_code = vsocs.facility_code'    

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_eight_key
  ## Updates the DataCsv table with data from the eight_keys table.
  ###########################################################################
  def self.update_with_eight_key
    names = EightKey::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += "eight_keys = TRUE "
    query_str += ' FROM eight_keys '
    query_str += 'WHERE data_csvs.cross = eight_keys.cross '
    query_str += 'AND eight_keys.cross IS NOT NULL'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_accreditation
  ## Updates the DataCsv table with data from the accreditations table.
  ###########################################################################
  def self.update_with_accreditation
    names = Accreditation::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = accreditations.#{name}) }.join(', ')
    query_str += ' FROM accreditations '
    query_str += 'WHERE data_csvs.cross = accreditations.cross '
    query_str += 'AND accreditations.cross IS NOT NULL '
    query_str += %(AND LOWER(accreditations.periods) LIKE '%current%' )
    query_str += "AND LOWER(accreditations.csv_accreditation_type) = 'institutional'; "

    query_str += 'UPDATE data_csvs SET '
    query_str += 'caution_flag = TRUE'
    query_str += ' FROM accreditations '
    query_str += 'WHERE data_csvs.cross = accreditations.cross '
    query_str += 'AND accreditations.cross IS NOT NULL '
    query_str += %(AND LOWER(accreditations.periods) LIKE '%current%' )
    query_str += 'AND accreditations.accreditation_status IS NOT NULL '
    query_str += "AND LOWER(accreditations.csv_accreditation_type) = 'institutional'; "

    query_str += 'UPDATE data_csvs SET '
    query_str += 'caution_flag_reason = CONCAT(data_csvs.caution_flag_reason,'
    query_str += "'Accreditation (', INITCAP(accreditations.accreditation_status), '),')"
    query_str += ' FROM accreditations '
    query_str += 'WHERE data_csvs.cross = accreditations.cross '
    query_str += 'AND accreditations.cross IS NOT NULL '
    query_str += %(AND LOWER(accreditations.periods) LIKE '%current%' )
    query_str += 'AND accreditations.accreditation_status IS NOT NULL '
    query_str += "AND LOWER(accreditations.csv_accreditation_type) = 'institutional'; "

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_arf_gibill
  ## Updates the DataCsv table with data from the arf_gibills table.
  ###########################################################################
  def self.update_with_arf_gibill
    names = ArfGibill::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = arf_gibills.#{name}) }.join(', ')
    query_str += ' FROM arf_gibills '
    query_str += 'WHERE data_csvs.facility_code = arf_gibills.facility_code'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_p911_tf
  ## Updates the DataCsv table with data from the p911_tfs table.
  ###########################################################################
  def self.update_with_p911_tf
    names = P911Tf::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = p911_tfs.#{name}) }.join(', ')
    query_str += ' FROM p911_tfs '
    query_str += 'WHERE data_csvs.facility_code = p911_tfs.facility_code'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_p911_yr
  ## Updates the DataCsv table with data from the p911_yrs table.
  ###########################################################################
  def self.update_with_p911_yr
    names = P911Yr::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = p911_yrs.#{name}) }.join(', ')
    query_str += ' FROM p911_yrs '
    query_str += 'WHERE data_csvs.facility_code = p911_yrs.facility_code'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_mou
  ## Updates the DataCsv table with data from the mous table.
  ###########################################################################
  def self.update_with_mou
    names = Mou::USE_COLUMNS.map(&:to_s)
    reason = 'DoD Probation For Military Tuition Assistance'

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = mous.#{name}) }.join(', ')
    query_str += ' FROM mous '
    query_str += 'WHERE data_csvs.ope6 = mous.ope6; '

    query_str += 'UPDATE data_csvs SET '
    query_str += 'caution_flag = TRUE'
    query_str += ' FROM mous '
    query_str += 'WHERE data_csvs.ope6 = mous.ope6 '
    query_str += 'AND mous.dod_status = TRUE; '
    #MPH
    query_str += 'UPDATE data_csvs SET '
    query_str += 'caution_flag_reason = CONCAT(data_csvs.caution_flag_reason,'
    query_str += "'#{reason},')"
    query_str += ' FROM mous '
    query_str += 'WHERE data_csvs.ope6 = mous.ope6 '
    query_str += "AND (LOWER(data_csvs.caution_flag_reason) NOT LIKE '%#{reason}%' OR "
    query_str += "data_csvs.caution_flag_reason IS NULL) "
    query_str += 'AND mous.dod_status = TRUE'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_scorecard
  ## Updates the DataCsv table with data from the scorecards table.
  ###########################################################################
  def self.update_with_scorecard
    names = Scorecard::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = scorecards.#{name}) }.join(', ')
    query_str += ' FROM scorecards '
    query_str += 'WHERE data_csvs.cross = scorecards.cross'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_ipeds_ic
  ## Updates the DataCsv table with data from the scorecards table.
  ###########################################################################
  def self.update_with_ipeds_ic
    names = IpedsIc::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = ipeds_ics.#{name}) }.join(', ')
    query_str += ' FROM ipeds_ics '
    query_str += 'WHERE data_csvs.cross = ipeds_ics.cross'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_ipeds_hd
  ## Updates the DataCsv table with data from the scorecards table.
  ###########################################################################
  def self.update_with_ipeds_hd
    names = IpedsHd::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = ipeds_hds.#{name}) }.join(', ')
    query_str += ' FROM ipeds_hds '
    query_str += 'WHERE data_csvs.cross = ipeds_hds.cross'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_ipeds_ic_ay
  ## Updates the DataCsv table with data from the scorecards table.
  ###########################################################################
  def self.update_with_ipeds_ic_ay
    names = IpedsIcAy::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = ipeds_ic_ays.#{name}) }.join(', ')
    query_str += ' FROM ipeds_ic_ays '
    query_str += 'WHERE data_csvs.cross = ipeds_ic_ays.cross'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_ipeds_ic_py
  ## Updates the DataCsv table with data from the scorecards table.
  ###########################################################################
  def self.update_with_ipeds_ic_py
    names = IpedsIcPy::USE_COLUMNS.map(&:to_s)

    query_str = ""
    names.each do |name|
      query_str += 'UPDATE data_csvs SET '
      query_str += %("#{name}" = ipeds_ic_pies.#{name})
      query_str += ' FROM ipeds_ic_pies '
      query_str += 'WHERE data_csvs.cross = ipeds_ic_pies.cross AND '
      query_str += "data_csvs.#{name} IS NULL; "
    end

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_sec702_school
  ## Updates the DataCsv table with data from the scorecards table. Note the
  ## definition of NULL does not return true when NOT LIKE compared with a 
  ## string.
  ###########################################################################
  def self.update_with_sec702_school
    names = Sec702School::USE_COLUMNS.map(&:to_s)
    reason = 'Does Not Offer Required In-State Tuition Rates'

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = sec702_schools.#{name}) }.join(', ')
    query_str += ' FROM sec702_schools '
    query_str += 'WHERE data_csvs.facility_code = sec702_schools.facility_code '
    query_str += 'AND sec702_schools.sec_702 IS NOT NULL '
    query_str += "AND lower(data_csvs.type) = 'public'; "

    query_str += 'UPDATE data_csvs SET '
    query_str += 'caution_flag = TRUE ' 
    query_str += ' FROM sec702_schools '
    query_str += 'WHERE data_csvs.facility_code = sec702_schools.facility_code '
    query_str += "AND sec702_schools.sec_702 = FALSE "
    query_str += "AND lower(data_csvs.type) = 'public'; "

    query_str += 'UPDATE data_csvs SET '
    query_str += 'caution_flag_reason = CONCAT(data_csvs.caution_flag_reason,'
    query_str += "'#{reason},')"
    query_str += ' FROM sec702_schools '
    query_str += 'WHERE data_csvs.facility_code = sec702_schools.facility_code '
    query_str += "AND (data_csvs.caution_flag_reason NOT LIKE '%#{reason}%' OR "
    query_str += "data_csvs.caution_flag_reason IS NULL) "
    query_str += "AND sec702_schools.sec_702 = FALSE "
    query_str += "AND lower(data_csvs.type) = 'public'"

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_sec702
  ## Updates the DataCsv table with data from the scorecards table.
  ###########################################################################
  def self.update_with_sec702
    names = Sec702::USE_COLUMNS.map(&:to_s)
    reason = 'Does Not Offer Required In-State Tuition Rates'

    query_str = ""
    names.each do |name|
      query_str += 'UPDATE data_csvs SET '
      query_str += %("#{name}" = sec702s.#{name})
      query_str += ' FROM sec702s '
      query_str += 'WHERE data_csvs.state = sec702s.state '
      query_str += "AND data_csvs.#{name} IS NULL "
      query_str += "AND lower(data_csvs.type) = 'public'; "
    end

    query_str += 'UPDATE data_csvs SET '
    query_str += 'caution_flag = TRUE ' 
    query_str += ' FROM sec702s '
    query_str += 'WHERE data_csvs.state = sec702s.state '
    query_str += "AND data_csvs.caution_flag IS NULL "
    query_str += "AND sec702s.sec_702 = FALSE "
    query_str += "AND lower(data_csvs.type) = 'public'; "

    query_str += 'UPDATE data_csvs SET '
    query_str += 'caution_flag_reason = CONCAT(data_csvs.caution_flag_reason,'
    query_str += "'#{reason},')"
    query_str += ' FROM sec702s '
    query_str += 'WHERE data_csvs.state = sec702s.state '
    query_str += "AND (data_csvs.caution_flag_reason NOT LIKE '%#{reason}%' OR "
    query_str += "data_csvs.caution_flag_reason IS NULL) "
    query_str += "AND sec702s.sec_702 = FALSE "
    query_str += "AND lower(data_csvs.type) = 'public'"

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_settlement
  ## Updates the DataCsv table with data from the settlements table.
  ###########################################################################
  def self.update_with_settlement
    query_str = 'UPDATE data_csvs SET '
    query_str += 'caution_flag = TRUE '
    query_str += ' FROM settlements '
    query_str += 'WHERE data_csvs.cross = settlements.cross; '

    query_str += 'UPDATE data_csvs SET '
    query_str += 'caution_flag_reason = CONCAT(data_csvs.caution_flag_reason,'
    query_str += "INITCAP(settlements.settlement_description), ',')"
    query_str += ' FROM settlements '
    query_str += 'WHERE data_csvs.cross = settlements.cross AND '
    query_str += "(data_csvs.caution_flag_reason NOT LIKE "
    query_str += "'%' || INITCAP(settlements.settlement_description) || '%' OR "
    query_str += "data_csvs.caution_flag_reason IS NULL)"

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_hcm
  ## Updates the DataCsv table with data from the hcm table.
  ###########################################################################
  def self.update_with_hcm
    query_str = 'UPDATE data_csvs SET '
    query_str += 'caution_flag = TRUE'
    query_str += ' FROM hcms '
    query_str += 'WHERE data_csvs.ope6 = hcms.ope6; '

    query_str += 'UPDATE data_csvs SET '
    query_str += 'caution_flag_reason = CONCAT(data_csvs.caution_flag_reason,'
    query_str += "'Heightened Cash Monitoring (', INITCAP(hcms.hcm_reason), '),')"
    query_str += ' FROM hcms '
    query_str += 'WHERE data_csvs.ope6 = hcms.ope6 AND '
    query_str += 'hcms.hcm_type IS NOT NULL AND '
    query_str += "(data_csvs.caution_flag_reason NOT LIKE "
    query_str += "'%' || INITCAP(hcms.hcm_reason) || '%' OR "
    query_str += "data_csvs.caution_flag_reason IS NULL)"

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_complaint
  ## Updates the DataCsv table with data from the complaint table.
  ###########################################################################
  def self.update_with_complaint
    Complaint.update_sums_by_ope6
    
    names = Complaint::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = complaints.#{name}) }.join(', ')
    query_str += ' FROM complaints '
    query_str += 'WHERE data_csvs.facility_code = complaints.facility_code '

    run_bulk_query(query_str)    
  end

  ###########################################################################
  ## update_with_outcome
  ## Updates the DataCsv table with data from the outcome table.
  ###########################################################################
  def self.update_with_outcome
    names = Outcome::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = outcomes.#{name}) }.join(', ')
    query_str += ' FROM outcomes '
    query_str += 'WHERE data_csvs.facility_code = outcomes.facility_code '

    run_bulk_query(query_str)    
  end
end

# frozen_string_literal: true

# By summing these complaint attributes accross a given facility_code, we obtain complaints for a campus, and by
# summing accross an OPE6 id that is obtained from the crosswalk when building out the institutions table, we
# arrive at the roll-up sum for the entire institution.
#
# To accomplish this, when saving each instance of a complaint, we check the the method :ok_to_sum? when the record is
# being saved. If not, all complaint counts remain at 0, otherwise we run the method :set_COMPLAINT_COLUMNS to set each
# complaint type to a 0 or a 1 based on a regular expression match of the :issue attribute with complaint category
# keywords. Summing all the complaints for a given facility_code is then done by the method :update_sums_by_fac
# (called after uploading the complaint CSV). Rolling up complaints to the institution (OPE6 id) is done by the method
# :update_sums_by_ope6 while the institution table is being built.
#
# Whether or not a complaint is counted, it must have (1) a facility_code, (2) be closed, and (3) not be invalid.

# frozen_string_literal: true

class Complaint < ImportableRecord
  STATUSES = %w[active closed pending reserved].freeze

  # COMPLAINT_COLUMNS contain substrings in each complaint that identify the type of complaint. There may
  # be several types of complaints for each campus (facility code), and institution (ope6). FAC_CODE_SUMS map the
  # instance's facility code-based summation field with the FAC_CODE_TERM. OPE6_SUMS map the instance's institution
  # level-based ope6 summation field with the FAC_CODE_TERM. COLS_USED_IN_INSTITUTION holds the columns that get copied
  # to the institution table during its build process.
  COMPLAINT_COLUMNS = {
    cfc: /.*/, cfbfc: /financial/i, cqbfc: /quality/i, crbfc: /refund/i, cmbfc: /recruit/i, cabfc: /accreditation/i,
    cdrbfc: /degree/i, cslbfc: /loans/i, cgbfc: /grade/i, cctbfc: /transfer/i, cjbfc: /job/i, ctbfc: /transcript/i,
    cobfc: /other/i
  }.freeze

  FAC_CODE_ROLL_UP_SUMS = {
    complaints_facility_code: :cfc,
    complaints_financial_by_fac_code: :cfbfc,
    complaints_quality_by_fac_code: :cqbfc,
    complaints_refund_by_fac_code: :crbfc,
    complaints_marketing_by_fac_code: :cmbfc,
    complaints_accreditation_by_fac_code: :cabfc,
    complaints_degree_requirements_by_fac_code: :cdrbfc,
    complaints_student_loans_by_fac_code: :cslbfc,
    complaints_grades_by_fac_code: :cgbfc,
    complaints_credit_transfer_by_fac_code: :cctbfc,
    complaints_job_by_fac_code: :cjbfc,
    complaints_transcript_by_fac_code: :ctbfc,
    complaints_other_by_fac_code: :cobfc
  }.freeze

  OPE6_ROLL_UP_SUMS = {
    complaints_main_campus_roll_up: :cfc,
    complaints_financial_by_ope_id_do_not_sum: :cfbfc,
    complaints_quality_by_ope_id_do_not_sum: :cqbfc,
    complaints_refund_by_ope_id_do_not_sum: :crbfc,
    complaints_marketing_by_ope_id_do_not_sum: :cmbfc,
    complaints_accreditation_by_ope_id_do_not_sum: :cabfc,
    complaints_degree_requirements_by_ope_id_do_not_sum: :cdrbfc,
    complaints_student_loans_by_ope_id_do_not_sum: :cslbfc,
    complaints_grades_by_ope_id_do_not_sum: :cgbfc,
    complaints_credit_transfer_by_ope_id_do_not_sum: :cctbfc,
    complaints_jobs_by_ope_id_do_not_sum: :cjbfc,
    complaints_transcript_by_ope_id_do_not_sum: :ctbfc,
    complaints_other_by_ope_id_do_not_sum: :cobfc
  }.freeze

  CSV_CONVERTER_INFO = {
    'case_id' => { column: :case_id, converter: Converters::BaseConverter },
    'escalation_level' => { column: :level, converter: Converters::BaseConverter },
    'status' => { column: :status, converter: Converters::DowncaseConverter },
    'case_owner' => { column: :case_owner, converter: Converters::BaseConverter },
    'school_name' => { column: :institution, converter: Converters::InstitutionConverter },
    'opeid' => { column: :ope, converter: Converters::OpeConverter },
    'facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'school_city' => { column: :city, converter: Converters::BaseConverter },
    'school_state' => { column: :state, converter: Converters::StateConverter },
    'date/time_opened' => { column: :submitted, converter: Converters::DateTimeConverter },
    'date_closed' => { column: :closed, converter: Converters::DateConverter },
    'sub_status' => { column: :closed_reason, converter: Converters::DowncaseConverter },
    'issue' => { column: :issues, converter: Converters::BaseConverter },
    'va_education_program' => { column: :education_benefits, converter: Converters::BaseConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :status, inclusion: { in: STATUSES }
  after_initialize :derive_dependent_columns

  def derive_dependent_columns
    self.ope6 = Converters::Ope6Converter.convert(ope)
    set_facility_code_complaint if ok_to_sum?
  end

  def ok_to_sum?
    status == 'closed' && closed_reason != 'invalid' && closed_reason.present?
  end

  def set_facility_code_complaint
    COMPLAINT_COLUMNS.each_pair { |complaint, issue_regex| self[complaint] = issues&.match?(issue_regex) ? 1 : 0 }
  end

  def self.rollup_sums(on_column, version_id)
    rollup_sums = on_column == :facility_code ? FAC_CODE_ROLL_UP_SUMS : OPE6_ROLL_UP_SUMS

    set_clause = []
    sum_clause = []
    # some ope codes are placeholders (e.g. 'VA000200', 'VA000300') and are assigned while
    # an institution is in the process of being assigned a 'real' ope id. These temporary
    # ope ids _should not_ be used to roll up complaints, since it will inevitably result
    # in complaints being attributed to institutions that have nothing to do with the offending
    # location. So, when doing ope6 rollups, we ignore anything that start with an 'A'. This
    # seems to be a reliable enough pattern to filter out these ephemeral ope ids.
    ope6_format_clause = on_column == :ope6 ? "AND NOT institutions.#{on_column} LIKE 'A%'" : ""

    rollup_sums.each_pair do |sum_column, complaint_column|
      set_clause << %("#{sum_column}" = sums.#{sum_column})
      sum_clause << %(SUM(COALESCE("#{complaint_column}", 0)) AS "#{sum_column}")
    end

    str = <<-SQL
      UPDATE institutions SET #{set_clause.join(', ')}
      FROM
        (SELECT "#{on_column}", #{sum_clause.join(', ')} FROM complaints GROUP BY #{on_column}) AS sums
        WHERE institutions.#{on_column} = sums.#{on_column} AND
          institutions.version_id = #{version_id} AND institutions.#{on_column} IS NOT NULL
          #{ope6_format_clause}
    SQL

    Complaint.connection.update(str)
  end

  # Updates these unreliable opes with onese from the crosswalk, which are maintained and more reliable.
  def self.update_ope_from_crosswalk
    Complaint.connection.update(<<-SQL)
      UPDATE complaints
        SET ope = crosswalks.ope, ope6 = crosswalks.ope6
        FROM crosswalks
        WHERE complaints.facility_code = crosswalks.facility_code AND crosswalks.ope IS NOT NULL
    SQL
  end
end

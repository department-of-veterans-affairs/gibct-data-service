# frozen_string_literal: true
module InstitutionBuilder
  TABLES = [
    Accreditation, ArfGiBill, Complaint, Crosswalk, EightKey, Hcm, IpedsHd,
    IpedsIcAy, IpedsIcPy, IpedsIc, Mou, Outcome, P911Tf, P911Yr, Scorecard,
    Sec702School, Sec702, Settlement, Sva, Vsoc, Weam
  ].freeze

  def self.columns_for_update(klass)
    table_name = klass.name.underscore.pluralize
    klass::COLS_USED_IN_INSTITUTION.map(&:to_s).map { |col| %("#{col}" = #{table_name}.#{col}) }.join(', ')
  end

  def self.default_timestamps_to_now
    query = 'ALTER TABLE institutions ALTER COLUMN updated_at SET DEFAULT now(); '
    query += 'ALTER TABLE institutions ALTER COLUMN created_at SET DEFAULT now();'

    ActiveRecord::Base.connection.execute(query)
  end

  def self.drop_default_timestamps
    query = 'ALTER TABLE institutions ALTER COLUMN updated_at DROP DEFAULT; '
    query += 'ALTER TABLE institutions ALTER COLUMN created_at DROP DEFAULT;'

    ActiveRecord::Base.connection.execute(query)
  end

  def self.run_insertions(version_number)
    initialize_with_weams(version_number)
    add_crosswalk(version_number)
    add_sva(version_number)
    add_vsoc(version_number)
    add_eight_key(version_number)
    add_accreditation(version_number)
    add_arf_gi_bill(version_number)
    add_p911_tf(version_number)
    add_p911_yr(version_number)
    add_mou(version_number)
    add_scorecard(version_number)
    add_ipeds_ic(version_number)
    add_ipeds_hd(version_number)
    add_ipeds_ic_ay(version_number)
    add_ipeds_ic_py(version_number)
    add_sec_702(version_number)
    add_settlement(version_number)
    add_hcm(version_number)
    add_complaint(version_number)
    add_outcome(version_number)
  end

  def self.run(user)
    error_msg = nil

    begin
      Institution.transaction do
        version = Version.create!(production: false, user: user)

        default_timestamps_to_now
        run_insertions(version.number)
        drop_default_timestamps
      end
    rescue StandardError => e
      error_msg = e.message
    end

    { version: Version.preview_version, error_msg: error_msg }
  end

  def self.initialize_with_weams(version_number)
    columns = Weam::COLS_USED_IN_INSTITUTION.map(&:to_s)

    str = "INSERT INTO institutions (#{columns.join(', ')}, version) "
    str += Weam.select(columns).select("#{version_number.to_i} as version").where(approved: true).to_sql

    Institution.connection.insert(str)
  end

  def self.add_crosswalk(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(Crosswalk)}
      FROM crosswalks
      WHERE institutions.facility_code = crosswalks.facility_code
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_sva(version_number)
    str = <<-SQL
      UPDATE institutions SET
        student_veteran = TRUE, student_veteran_link = svas.student_veteran_link
      FROM svas
      WHERE institutions.cross = svas.cross AND svas.cross IS NOT NULL
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_vsoc(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(Vsoc)}
      FROM vsocs
      WHERE institutions.facility_code = vsocs.facility_code
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_eight_key(version_number)
    str = <<-SQL
      UPDATE institutions SET eight_keys = TRUE
      FROM eight_keys
      WHERE institutions.cross = eight_keys.cross
        AND eight_keys.cross IS NOT NULL
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_accreditation(version_number)
    # Set the accreditation_type according to the hierarchy hybrid < national < regional
    # We include only those accreditation that are institutional and currently active.
    str = <<-SQL
      UPDATE institutions SET
        accreditation_type = accreditations.accreditation_type
      FROM accreditations
      WHERE institutions.cross = accreditations.cross
        AND accreditations.cross IS NOT NULL
        AND accreditations.periods LIKE '%current%'
        AND accreditations.csv_accreditation_type = 'institutional'
        AND institutions.version = #{version_number}
        AND accreditations.accreditation_type =
    SQL

    %w(hybrid national regional).each do |acc_type|
      Institution.connection.update(str + " '#{acc_type}';")
    end

    # Set the accreditation_status according to the hierarchy probation < show cause aligned by
    # accreditation_type
    str = <<-SQL
      UPDATE institutions SET
        accreditation_status = accreditations.accreditation_status
      FROM accreditations
      WHERE institutions.cross = accreditations.cross
        AND institutions.accreditation_type = accreditations.accreditation_type
        AND accreditations.cross IS NOT NULL
        AND accreditations.periods LIKE '%current%'
        AND accreditations.csv_accreditation_type = 'institutional'
        AND institutions.version = #{version_number}
        AND accreditations.accreditation_status =
    SQL

    ['probation', 'show cause'].each do |acc_status|
      Institution.connection.update(str + " '#{acc_status}';")
    end

    # Sets the caution flag for all accreditations that have a non-null status. Note,
    # that institutional type accreditations are always, null, probation, or show cause.
    str = <<-SQL
      UPDATE institutions SET caution_flag = TRUE
      FROM accreditations
      WHERE institutions.cross = accreditations.cross
        AND accreditations.cross IS NOT NULL
        AND accreditations.periods LIKE '%current%'
        AND accreditations.accreditation_status IS NOT NULL
        AND accreditations.csv_accreditation_type = 'institutional'
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)

    # Sets the caution flag reason for all accreditations that have a non-null status.
    # The innermost subquery retrieves a distinct set of statuses (it is plausible that
    # identical statuses may apply to the same school but from different agencies).
    str = <<-SQL
      UPDATE institutions SET
        caution_flag_reason = concat_ws(', ', caution_flag_reason, reasons_list.reasons)
      FROM (
        SELECT "cross",
          array_to_string(array_agg(distinct('Accreditation ('||accreditation_status||')')), ', ') AS reasons
        FROM accreditations
        WHERE "cross" IS NOT NULL
          AND accreditation_status IS NOT NULL
          AND periods LIKE '%current%'
          AND csv_accreditation_type = 'institutional'
          GROUP BY "cross" ) reasons_list
      WHERE institutions.cross = reasons_list.cross
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_arf_gi_bill(version_number)
    str = <<-SQL
      UPDATE institutions SET gibill = arf_gi_bills.gibill
      FROM arf_gi_bills
      WHERE institutions.facility_code = arf_gi_bills.facility_code
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_p911_tf(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(P911Tf)}
      FROM p911_tfs
      WHERE institutions.facility_code = p911_tfs.facility_code
      AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_p911_yr(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(P911Yr)}
      FROM p911_yrs
      WHERE institutions.facility_code = p911_yrs.facility_code
      AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_mou(version_number)
    reason = 'DoD Probation For Military Tuition Assistance'

    # Sets the caution flag for any approved school having a probatiton or title IV non-compliance (status == true)
    str = <<-SQL
      UPDATE institutions SET
        dodmou = mous.dodmou,
        caution_flag = CASE WHEN mous.dod_status = TRUE THEN TRUE ELSE caution_flag END
      FROM mous
      WHERE institutions.ope6 = mous.ope6
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)

    # Sets dodmou for any approved school having a probatiton or title IV non-compliance status.
    # The caution flag reason is only affected by a DoD type probation status
    str = <<-SQL
      UPDATE institutions SET
        caution_flag_reason = concat_ws(', ', caution_flag_reason, reasons_list.reason)
      FROM (
        SELECT distinct(ope6), '#{reason}' AS reason FROM mous
        WHERE dod_status = TRUE) as reasons_list
      WHERE institutions.ope6 = reasons_list.ope6
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_scorecard(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(Scorecard)}
      FROM scorecards
      WHERE institutions.cross = scorecards.cross
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_ic(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(IpedsIc)}
      FROM ipeds_ics
      WHERE institutions.cross = ipeds_ics.cross
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_hd(version_number)
    str = <<-SQL
      UPDATE institutions SET vet_tuition_policy_url = ipeds_hds.vet_tuition_policy_url
      FROM ipeds_hds
      WHERE institutions.cross = ipeds_hds.cross
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_ic_ay(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(IpedsIcAy)}
      FROM ipeds_ic_ays
      WHERE institutions.cross = ipeds_ic_ays.cross
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_ic_py(version_number)
    columns = IpedsIcPy::COLS_USED_IN_INSTITUTION.map(&:to_s).map do |col|
      %("#{col}" = CASE WHEN institutions.#{col} IS NULL THEN ipeds_ic_pies.#{col} ELSE institutions.#{col} END)
    end.join(', ')

    str = <<-SQL
      UPDATE institutions SET #{columns}
      FROM ipeds_ic_pies
      WHERE institutions.cross = ipeds_ic_pies.cross
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_sec_702(version_number)
    # When overlapping, sec_702 data from sec702_schools has precedence over data from sec702_schools, and
    # only approved public schools can be SEC 702 complaint
    reason = 'Does Not Offer Required In-State Tuition Rates'

    str = <<-SQL
      UPDATE institutions SET
        sec_702 = s702_list.sec_702, caution_flag = NOT s702_list.sec_702,
        caution_flag_reason = CASE WHEN NOT s702_list.sec_702
          THEN concat_ws(',', caution_flag_reason, '#{reason}') ELSE caution_flag_reason
        END
      FROM (
        SELECT facility_code, sec702s.sec_702 FROM institutions
          INNER JOIN sec702s ON sec702s.state = institutions.state
            EXCEPT SELECT facility_code, sec_702 FROM sec702_schools
            UNION SELECT facility_code, sec_702 FROM sec702_schools
      ) AS s702_list
      WHERE institutions.facility_code = s702_list.facility_code
        AND institutions.institution_type_name = 'public'
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_settlement(version_number)
    # Sets caution flags and caution flag reasons if the corresponing approved school (by IPEDs id)
    # has an entry in the settlements table.
    str = <<-SQL
      UPDATE institutions SET
        caution_flag = TRUE,
        caution_flag_reason = concat_ws(',', caution_flag_reason, settlement_list.descriptions)
      FROM (
        SELECT "cross", array_to_string(array_agg(distinct(settlement_description)), ', ') AS descriptions
        FROM settlements
        WHERE "cross" IS NOT NULL
        GROUP BY "cross"
      ) settlement_list
      WHERE institutions.cross = settlement_list.cross
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_hcm(version_number)
    # Sets caution flags and caution flag reasons if the corresponing approved school (by ope6)
    # has an entry in the hcms table.
    str = <<-SQL
      UPDATE institutions SET
        caution_flag = TRUE,
        caution_flag_reason = concat_ws(',', caution_flag_reason, hcm_list.reasons)
      FROM (
        SELECT "ope6",
          array_to_string(array_agg(distinct('Heightened Cash Monitoring (' || hcm_reason || ')')), ', ') AS reasons
        FROM hcms
        GROUP BY ope6
      ) hcm_list
      WHERE institutions.ope6 = hcm_list.ope6
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_complaint(version_number)
    Complaint.update_ope_from_crosswalk
    Complaint.rollup_sums(:facility_code, version_number)
    Complaint.rollup_sums(:ope6, version_number)
  end

  def self.add_outcome(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(Outcome)}
      FROM outcomes
      WHERE institutions.facility_code = outcomes.facility_code
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end
end

# frozen_string_literal: true
module InstitutionBuilder
  TABLES = [
    Accreditation, ArfGiBill, Complaint, Crosswalk, EightKey, Hcm, IpedsHd,
    IpedsIcAy, IpedsIcPy, IpedsIc, Mou, Outcome, P911Tf, P911Yr, Scorecard,
    Sec702School, Sec702, Settlement, Sva, Vsoc, Weam
  ].freeze

  def self.buildable?
    TABLES.map(&:count).reject(&:positive?).blank?
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
    add_arf_gi_bill
    add_p911_tf
    add_p911_yr
    add_mou
    add_scorecard
    add_ipeds_ic
    add_ipeds_hd
    add_ipeds_ic_ay
    add_ipeds_ic_py
    add_sec_702
    add_settlement
    add_hcm
    add_complaint
    add_outcome
  end

  def self.run(user)
    return nil unless buildable?
    version = Version.create(production: false, user: user)

    default_timestamps_to_now
    run_insertions(version.number)
    drop_default_timestamps

    version
  end

  def self.initialize_with_weams(version_number)
    columns = Weam::USE_COLUMNS.map(&:to_s)

    institutions = Weam.select(columns).where(approved: true).map(&:attributes).each_with_object([]) do |weam, a|
      a << Institution.new(weam.except('id').merge(version: version_number))
    end

    # No validations here, Weam was validated on import - don't need to waste time with unique checks
    Institution.import institutions, validate: false, ignore: true
  end

  def self.add_crosswalk(version_number)
    columns = Crosswalk::USE_COLUMNS.map(&:to_s).map { |col| %("#{col}" = crosswalks.#{col}) }.join(', ')

    str = <<-SQL
      UPDATE institutions SET #{columns}
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
    columns = Vsoc::USE_COLUMNS.map(&:to_s).map { |col| %("#{col}" = vsocs.#{col}) }.join(', ')

    str = <<-SQL
      UPDATE institutions SET #{columns}
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
      UPDATE institutions SET accreditation_type = CASE
        WHEN at_types @> '{ regional }' THEN 'regional'
        WHEN at_types @> '{ national }' THEN 'national'
        WHEN at_types @> '{ hybrid }' THEN 'hybrid'
        ELSE NULL
      END
      FROM (
        SELECT "cross", array_agg(DISTINCT(accreditation_type)) AS at_types
        FROM accreditations
        WHERE "cross" IS NOT NULL
          AND accreditation_type IS NOT NULL
          AND periods LIKE '%current%'
          AND csv_accreditation_type = 'institutional'
        GROUP BY "cross") AS cross_type_arr
      WHERE cross_type_arr.cross = institutions.cross
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)

    # Set the accreditation_status according to the hierarchy probation < show cause aligned by
    # accreditation_type
    str = <<-SQL
      UPDATE institutions SET accreditation_status = CASE
        WHEN as_statuses @> '{ show cause }' THEN 'show cause'
        WHEN as_statuses @> '{ probation }' THEN 'probation'
        ELSE NULL
      END
      FROM (
        SELECT "cross", accreditation_type, array_agg(DISTINCT(accreditation_status)) AS as_statuses
        FROM accreditations
        WHERE "cross" IS NOT NULL
          AND accreditation_type IS NOT NULL
          AND (accreditation_status = 'probation' OR accreditation_status = 'show cause')
          AND periods LIKE '%current%'
          AND csv_accreditation_type = 'institutional'
        GROUP BY "cross", accreditation_type) AS cross_status_arr
      WHERE institutions.cross = cross_status_arr.cross
        AND institutions.accreditation_type = cross_status_arr.accreditation_type
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)

    # Sets the caution flag for all accreditations that have a non-null status. Note,
    # that institutional type accreditations are always, null, probation, or show cause.
    str = <<-SQL
      UPDATE institutions SET caution_flag = TRUE
      FROM accreditations
      WHERE institutions.cross = accreditations.cross
        AND accreditations.cross IS NOT NULL
        AND accreditations.periods LIKE '%current%'
        AND accreditations.accreditation_status IS NOT NULL
        AND accreditations.csv_accreditation_type = 'institutional';
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
      WHERE institutions.cross = reasons_list.cross;
    SQL

    Institution.connection.update(str)
  end

  def self.add_arf_gi_bill
    str = <<-SQL
      UPDATE institutions SET gibill = arf_gi_bills.gibill
      FROM arf_gi_bills
      WHERE institutions.facility_code = arf_gi_bills.facility_code;
    SQL

    Institution.connection.update(str)
  end

  def self.add_p911_tf
    columns = P911Tf::USE_COLUMNS.map(&:to_s).map { |col| %("#{col}" = p911_tfs.#{col}) }.join(', ')

    str = <<-SQL
      UPDATE institutions SET #{columns}
      FROM p911_tfs
      WHERE institutions.facility_code = p911_tfs.facility_code;
    SQL

    Institution.connection.update(str)
  end

  def self.add_p911_yr
    columns = P911Yr::USE_COLUMNS.map(&:to_s).map { |col| %("#{col}" = p911_yrs.#{col}) }.join(', ')

    str = <<-SQL
      UPDATE institutions SET #{columns}
      FROM p911_yrs
      WHERE institutions.facility_code = p911_yrs.facility_code;
    SQL

    Institution.connection.update(str)
  end

  def self.add_mou
    reason = 'DoD Probation For Military Tuition Assistance'

    # Sets the caution flag for any approved school having a probatiton or title IV non-compliance (status == true)
    str = <<-SQL
      UPDATE institutions SET
        dodmou = mous.dodmou,
        caution_flag = CASE WHEN mous.dod_status = TRUE THEN TRUE ELSE caution_flag END
      FROM mous
      WHERE institutions.ope6 = mous.ope6;
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
      WHERE institutions.ope6 = reasons_list.ope6;
    SQL

    Institution.connection.update(str)
  end

  def self.add_scorecard
    columns = Scorecard::USE_COLUMNS.map(&:to_s).map { |col| %("#{col}" = scorecards.#{col}) }.join(', ')

    str = <<-SQL
      UPDATE institutions SET #{columns}
      FROM scorecards
      WHERE institutions.cross = scorecards.cross;
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_ic
    columns = IpedsIc::USE_COLUMNS.map(&:to_s).map { |col| %("#{col}" = ipeds_ics.#{col}) }.join(', ')

    str = <<-SQL
      UPDATE institutions SET #{columns}
      FROM ipeds_ics
      WHERE institutions.cross = ipeds_ics.cross;
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_hd
    str = <<-SQL
      UPDATE institutions SET vet_tuition_policy_url = ipeds_hds.vet_tuition_policy_url
      FROM ipeds_hds
      WHERE institutions.cross = ipeds_hds.cross;
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_ic_ay
    columns = IpedsIcAy::USE_COLUMNS.map(&:to_s).map { |col| %("#{col}" = ipeds_ic_ays.#{col}) }.join(', ')

    str = <<-SQL
      UPDATE institutions SET #{columns}
      FROM ipeds_ic_ays
      WHERE institutions.cross = ipeds_ic_ays.cross;
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_ic_py
    columns = IpedsIcPy::USE_COLUMNS.map(&:to_s).map do |col|
      %("#{col}" = CASE WHEN institutions.#{col} IS NULL THEN ipeds_ic_pies.#{col} ELSE institutions.#{col} END)
    end.join(', ')

    str = <<-SQL
      UPDATE institutions SET #{columns}
      FROM ipeds_ic_pies
      WHERE institutions.cross = ipeds_ic_pies.cross;
    SQL

    Institution.connection.update(str)
  end

  def self.add_sec_702
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
        AND institutions.institution_type_name = 'public';
    SQL

    Institution.connection.update(str)
  end

  def self.add_settlement
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
      WHERE institutions.cross = settlement_list.cross;
    SQL

    Institution.connection.update(str)
  end

  def self.add_hcm
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
      WHERE institutions.ope6 = hcm_list.ope6;
    SQL

    Institution.connection.update(str)
  end

  def self.add_complaint
    columns = Complaint::USE_COLUMNS.map(&:to_s).map { |col| %("#{col}" = complaints.#{col}) }.join(', ')

    # Sets the complaint data for each school, matching by facility code.
    str = <<-SQL
      UPDATE institutions SET #{columns}
      FROM complaints
      WHERE institutions.facility_code = complaints.facility_code;
    SQL

    Institution.connection.update(str)

    # TODO: Rollup sums by facility_code and ope6
  end

  def self.add_outcome
    columns = Outcome::USE_COLUMNS.map(&:to_s).map { |col| %("#{col}" = outcomes.#{col}) }.join(', ')

    # Sets the outcome data for each school, matching by facility code.
    str = <<-SQL
      UPDATE institutions SET #{columns}
      FROM outcomes
      WHERE institutions.facility_code = outcomes.facility_code;
    SQL

    Institution.connection.update(str)
  end
end

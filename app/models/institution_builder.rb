# frozen_string_literal: true

module InstitutionBuilder
  TABLES = [
    AccreditationAction, AccreditationInstituteCampus, AccreditationRecord,
    ArfGiBill, Complaint, Crosswalk, EightKey, Hcm, IpedsHd,
    IpedsIcAy, IpedsIcPy, IpedsIc, Mou, Outcome, P911Tf, P911Yr, Scorecard,
    Sec702School, Sec702, Settlement, Sva, Vsoc, Weam, CalculatorConstant,
    IpedsCipCode, StemCipCode, YellowRibbonProgramSource, SchoolClosure,
    Sec109ClosedSchool
  ].freeze

  ACCREDITATION_JOIN_CLAUSES = [
    'institutions.ope6 = accreditation_institute_campuses.ope6',
    'institutions.ope = accreditation_institute_campuses.ope'
  ].freeze

  def self.columns_for_update(klass)
    table_name = klass.name.underscore.pluralize
    klass::COLS_USED_IN_INSTITUTION.map(&:to_s).map { |col| %("#{col}" = #{table_name}.#{col}) }.join(', ')
  end

  def self.add_vet_tec_provider(version_number)
    str = <<-SQL
    UPDATE institutions SET vet_tec_provider = TRUE
      WHERE substring(institutions.facility_code, 2 , 1) = 'V'
        AND institutions.version = #{version_number};
    SQL
    Institution.connection.update(str)
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
    add_stem_offered(version_number)
    add_yellow_ribbon_programs(version_number)
    add_school_closure(version_number)
    add_vet_tec_provider(version_number)
    add_sec109_closed_school(version_number)
    build_zip_code_rates_from_weams(version_number)
  end

  def self.run(user)
    error_msg = nil
    version = Version.create!(production: false, user: user)

    begin
      Institution.transaction do
        run_insertions(version.number)
      end

      version.update(completed_at: Time.now.utc.to_s(:db))

      notice = 'Institution build was successful'
      success = true
    rescue ActiveRecord::StatementInvalid => e
      notice = 'There was an error occurring at the database level'
      error_msg = e.original_exception.result.error_message
      Rails.logger.error "#{notice}: #{error_msg}"

      success = false
    rescue StandardError => e
      notice = 'There was an error of unexpected origin'
      error_msg = e.message
      Rails.logger.error "#{notice}: #{error_msg}"

      success = false
    end

    version.delete unless success

    { version: Version.current_preview, error_msg: error_msg, notice: notice, success: success }
  end

  def self.initialize_with_weams(version_number)
    columns = Weam::COLS_USED_IN_INSTITUTION.map(&:to_s)
    timestamp = Time.now.utc.to_s(:db)
    conn = ActiveRecord::Base.connection

    str = "INSERT INTO institutions (#{columns.join(', ')}, version, created_at, updated_at) "
    str += Weam.select(columns)
               .select("#{version_number.to_i} as version")
               .select("#{conn.quote(timestamp)} as created_at")
               .select("#{conn.quote(timestamp)} as updated_at")
               .to_sql

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

  def self.add_sec109_closed_school(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(Sec109ClosedSchool)}
      FROM  sec109_closed_schools
      WHERE institutions.facility_code = sec109_closed_schools.facility_code
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
    # Set the `accreditation_type`, `accreditation_status`, `caution_flag` and `caution_reason` by joining on
    # `ope6` for more broad match, then `ope` for a more specific match because not all institutions
    # have a unique `ope` provided.
    # Set the accreditation_type according to the hierarchy hybrid < national < regional
    # We include only those accreditation that are institutional and currently active.
    str = <<-SQL
      UPDATE institutions SET
        accreditation_type = accreditation_records.accreditation_type
      FROM accreditation_institute_campuses, accreditation_records
      WHERE {{JOIN_CLAUSE}}
        AND accreditation_institute_campuses.dapip_id = accreditation_records.dapip_id
        AND institutions.ope IS NOT NULL
        AND accreditation_records.accreditation_end_date IS NULL
        AND accreditation_records.program_id = 1
        AND institutions.version = #{version_number}
        AND accreditation_records.accreditation_type = {{ACC_TYPE}};
    SQL
    ACCREDITATION_JOIN_CLAUSES.each do |join_clause|
      %w[hybrid national regional].each do |acc_type|
        Institution.connection.update(str.gsub('{{JOIN_CLAUSE}}', join_clause).gsub('{{ACC_TYPE}}', "'#{acc_type}'"))
      end
    end

    str = <<-SQL
      UPDATE institutions
      SET accreditation_status = aa.action_description,
          caution_flag = TRUE,
          caution_flag_reason = concat(aa.action_description, ' (', aa.justification_description, ')')
      FROM accreditation_institute_campuses, accreditation_actions aa
      WHERE {{JOIN_CLAUSE}}
        -- has received a probationary action
        AND aa.id = (
          SELECT id from accreditation_actions
          WHERE action_description IN (#{AccreditationAction::PROBATIONARY_STATUSES.join(', ')})
          AND program_id = 1
          AND dapip_id = accreditation_institute_campuses.dapip_id
          ORDER BY action_date DESC
          LIMIT 1
        )
        -- has not received a restorative action after the probrationary action
        AND (
          SELECT id from accreditation_actions
            WHERE action_description in (#{AccreditationAction::RESTORATIVE_STATUSES.join(', ')})
            AND dapip_id = aa.dapip_id
            AND program_id = 1
            AND action_date > aa.action_date
            LIMIT 1
        ) IS NULL
        AND institutions.ope IS NOT NULL
        AND institutions.version = #{version_number};
    SQL

    ACCREDITATION_JOIN_CLAUSES.each do |join_clause|
      Institution.connection.update(str.gsub('{{JOIN_CLAUSE}}', join_clause))
    end
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

    # Sets the caution flag for any approved school having a probatiton (status == true)
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
      UPDATE institutions SET #{columns_for_update(IpedsHd)}
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
        sec_702 = s702_list.sec_702,
        caution_flag = (NOT s702_list.sec_702) OR caution_flag,
        caution_flag_reason = CASE WHEN NOT s702_list.sec_702
          THEN concat_ws(', ', caution_flag_reason, '#{reason}') ELSE caution_flag_reason
        END
      FROM (
        SELECT facility_code, sec702s.sec_702 FROM institutions
          INNER JOIN sec702s ON sec702s.state = institutions.state
            EXCEPT SELECT facility_code, sec_702 FROM sec702_schools
            UNION SELECT facility_code, sec_702 FROM sec702_schools
      ) AS s702_list
      WHERE institutions.facility_code = s702_list.facility_code
        AND institutions.institution_type_name = 'PUBLIC'
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
        caution_flag_reason = concat_ws(', ', caution_flag_reason, settlement_list.descriptions)
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
        caution_flag_reason = concat_ws(', ', caution_flag_reason, hcm_list.reasons)
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

  def self.add_stem_offered(version_number)
    str = <<-SQL
      UPDATE institutions SET stem_offered=true
      FROM ipeds_cip_codes, stem_cip_codes
      WHERE institutions.cross = ipeds_cip_codes.cross
        AND institutions.cross IS NOT NULL
        AND ipeds_cip_codes.ctotalt > 0
        AND ipeds_cip_codes.cipcode = stem_cip_codes.twentyten_cip_code
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.add_yellow_ribbon_programs(version_number)
    str = <<-SQL
      INSERT INTO yellow_ribbon_programs
        (version, institution_id, degree_level, division_professional_school,
          number_of_students, contribution_amount, created_at, updated_at)
        (SELECT
          i.version, i.id, yrs.degree_level, yrs.division_professional_school,
            yrs.number_of_students, yrs.contribution_amount, NOW(), NOW()
          FROM institutions as i, yellow_ribbon_program_sources as yrs
          WHERE i.facility_code = yrs.facility_code
          AND i.version = ?);
    SQL

    sql = Institution.send(:sanitize_sql, [str, version_number])
    Institution.connection.execute(sql)
  end

  def self.add_school_closure(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(SchoolClosure)}
      FROM school_closures
      WHERE institutions.facility_code = school_closures.facility_code
        AND institutions.version = #{version_number};
    SQL

    Institution.connection.update(str)
  end

  def self.build_zip_code_rates_from_weams(version_number)
    timestamp = Time.now.utc.to_s(:db)
    conn = ActiveRecord::Base.connection

    str = <<-SQL
      INSERT INTO zipcode_rates (
        zip_code,
        mha_rate_grandfathered,
        mha_rate,
        version,
        created_at,
        updated_at
      )
      SELECT
        zip,
        bah,
        dod_bah,
        ?,
        #{conn.quote(timestamp)},
        #{conn.quote(timestamp)}
      FROM weams
      WHERE country = 'USA'
        AND bah IS NOT null
        AND dod_bah IS NOT null
      GROUP BY zip, bah, dod_bah
      ORDER BY zip
    SQL

    sql = ZipcodeRate.send(:sanitize_sql, [str, version_number])
    ZipcodeRate.connection.execute(sql)
  end
end

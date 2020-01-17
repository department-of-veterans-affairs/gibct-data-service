# frozen_string_literal: true

module InstitutionBuilder
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
      from versions
      WHERE substring(institutions.facility_code, 2 , 1) = 'V'
        AND versions.number = #{version_number}
        AND versions.id = institutions.version_id;
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
    add_extension_campus_type(version_number)
    add_sec109_closed_school(version_number)
    build_zip_code_rates_from_weams(version_number)
    build_institution_programs(version_number)
    build_school_certifying_officials(version_number)
    add_sco_institution_id(version_number)
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
      error_msg = e.message
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
    conn = ApplicationRecord.connection

    str = "INSERT INTO institutions (#{columns.join(', ')}, version, created_at, updated_at, version_id) "
    str += Weam
           .select(columns)
           .select("#{version_number.to_i} as version")
           .select("#{conn.quote(timestamp)} as created_at")
           .select("#{conn.quote(timestamp)} as updated_at")
           .select('v.id as version_id')
           .to_sql
    str += "INNER JOIN versions v ON v.number = #{version_number}"
    Institution.connection.insert(str)

    # remove duplicates
    delete_str = <<-SQL
      DELETE FROM institutions WHERE id NOT IN (
        SELECT MIN(id) FROM institutions WHERE version = ? GROUP BY UPPER(facility_code)
      ) AND version = ?;
    SQL
    sql = InstitutionProgram.send(:sanitize_sql, [delete_str, version_number, version_number])

    Institution.connection.execute(sql)
  end

  def self.add_crosswalk(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(Crosswalk)}
      FROM crosswalks, versions
      WHERE institutions.facility_code = crosswalks.facility_code
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
    SQL

    Institution.connection.update(str)
  end

  def self.add_sec109_closed_school(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(Sec109ClosedSchool)}
      FROM  sec109_closed_schools, versions
      WHERE institutions.facility_code = sec109_closed_schools.facility_code
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
    SQL

    Institution.connection.update(str)
  end

  def self.add_sva(version_number)
    str = <<-SQL
      UPDATE institutions SET
        student_veteran = TRUE, student_veteran_link = svas.student_veteran_link
      FROM svas, versions
      WHERE institutions.cross = svas.cross AND svas.cross IS NOT NULL
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
    SQL

    Institution.connection.update(str)
  end

  def self.add_vsoc(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(Vsoc)}
      FROM vsocs, versions
      WHERE institutions.facility_code = vsocs.facility_code
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
    SQL

    Institution.connection.update(str)
  end

  def self.add_eight_key(version_number)
    str = <<-SQL
      UPDATE institutions SET eight_keys = TRUE
      FROM eight_keys, versions
      WHERE institutions.cross = eight_keys.cross
        AND eight_keys.cross IS NOT NULL
        AND versions.number = #{version_number}
        AND versions.id = institutions.version_id;
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
      FROM accreditation_institute_campuses, accreditation_records, versions
      WHERE {{JOIN_CLAUSE}}
        AND accreditation_institute_campuses.dapip_id = accreditation_records.dapip_id
        AND institutions.ope IS NOT NULL
        AND accreditation_records.accreditation_end_date IS NULL
        AND accreditation_records.program_id = 1
        AND versions.number = #{version_number}
        AND versions.id = institutions.version_id
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
      FROM accreditation_institute_campuses, accreditation_actions aa, versions
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
        AND versions.number = #{version_number}
        AND versions.id = institutions.version_id;
    SQL

    ACCREDITATION_JOIN_CLAUSES.each do |join_clause|
      Institution.connection.update(str.gsub('{{JOIN_CLAUSE}}', join_clause))
    end
  end

  def self.add_arf_gi_bill(version_number)
    str = <<-SQL
      UPDATE institutions SET gibill = arf_gi_bills.gibill
      FROM arf_gi_bills, versions
      WHERE institutions.facility_code = arf_gi_bills.facility_code
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
    SQL

    Institution.connection.update(str)
  end

  def self.add_p911_tf(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(P911Tf)}
      FROM p911_tfs, versions
      WHERE institutions.facility_code = p911_tfs.facility_code
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
    SQL

    Institution.connection.update(str)
  end

  def self.add_p911_yr(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(P911Yr)}
      FROM p911_yrs, versions
      WHERE institutions.facility_code = p911_yrs.facility_code
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
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
      FROM mous, versions
      WHERE institutions.ope6 = mous.ope6
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
    SQL

    Institution.connection.update(str)

    # Sets dodmou for any approved school having a probatiton or title IV non-compliance status.
    # The caution flag reason is only affected by a DoD type probation status
    str = <<-SQL
      UPDATE institutions SET
        caution_flag_reason = concat_ws(', ', caution_flag_reason, reasons_list.reason)
      FROM (
        SELECT distinct(ope6), '#{reason}' AS reason FROM mous
        WHERE dod_status = TRUE) as reasons_list, versions
      WHERE institutions.ope6 = reasons_list.ope6
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
    SQL

    Institution.connection.update(str)
  end

  def self.add_scorecard(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(Scorecard)}
      FROM scorecards, versions
      WHERE institutions.cross = scorecards.cross
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_ic(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(IpedsIc)}
      FROM ipeds_ics, versions
      WHERE institutions.cross = ipeds_ics.cross
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_hd(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(IpedsHd)}
      FROM ipeds_hds, versions
      WHERE institutions.cross = ipeds_hds.cross
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_ic_ay(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(IpedsIcAy)}
      FROM ipeds_ic_ays, versions
      WHERE institutions.cross = ipeds_ic_ays.cross
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_ic_py(version_number)
    columns = IpedsIcPy::COLS_USED_IN_INSTITUTION.map(&:to_s).map do |col|
      %("#{col}" = CASE WHEN institutions.#{col} IS NULL THEN ipeds_ic_pies.#{col} ELSE institutions.#{col} END)
    end.join(', ')

    str = <<-SQL
      UPDATE institutions SET #{columns}
      FROM ipeds_ic_pies, versions
      WHERE institutions.cross = ipeds_ic_pies.cross
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
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
      ) AS s702_list, versions
      WHERE institutions.facility_code = s702_list.facility_code
        AND institutions.institution_type_name = 'PUBLIC'
        AND versions.number = #{version_number}
        AND versions.id = institutions.version_id;
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
      ) settlement_list, versions
      WHERE institutions.cross = settlement_list.cross
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
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
      ) hcm_list, versions
      WHERE institutions.ope6 = hcm_list.ope6
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
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
      FROM outcomes, versions
      WHERE institutions.facility_code = outcomes.facility_code
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
    SQL

    Institution.connection.update(str)
  end

  def self.add_stem_offered(version_number)
    str = <<-SQL
      UPDATE institutions SET stem_offered=true
      FROM ipeds_cip_codes, stem_cip_codes, versions
      WHERE institutions.cross = ipeds_cip_codes.cross
        AND institutions.cross IS NOT NULL
        AND ipeds_cip_codes.ctotalt > 0
        AND ipeds_cip_codes.cipcode = stem_cip_codes.twentyten_cip_code
        AND versions.number = #{version_number}
        AND versions.id = institutions.version_id;
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
          FROM institutions as i, yellow_ribbon_program_sources as yrs, versions
          WHERE i.facility_code = yrs.facility_code
          AND versions.number = #{version_number}
          AND versions.id = i.version_id);
    SQL

    sql = Institution.send(:sanitize_sql, [str, version_number])
    Institution.connection.execute(sql)
  end

  def self.add_school_closure(version_number)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(SchoolClosure)}
      FROM school_closures, versions
      WHERE institutions.facility_code = school_closures.facility_code
      AND versions.number = #{version_number}
      AND versions.id = institutions.version_id;
    SQL

    Institution.connection.update(str)
  end

  def self.build_zip_code_rates_from_weams(version_number)
    timestamp = Time.now.utc.to_s(:db)
    conn = ApplicationRecord.connection

    str = <<-SQL
    INSERT INTO zipcode_rates (
      zip_code,
      mha_rate_grandfathered,
      mha_rate,
      mha_name,
      version,
      created_at,
      updated_at,
      version_id
    )
    SELECT
      zip,
      bah,
      dod_bah,
      concat_ws(', ', physical_city, physical_state) as physical_location,
      v.number,
      #{conn.quote(timestamp)},
      #{conn.quote(timestamp)},
      v.id
      FROM weams INNER JOIN versions v ON v.number = ?
    WHERE country = 'USA'
      AND bah IS NOT null
      AND dod_bah IS NOT null
    GROUP BY zip, bah, dod_bah, physical_location, v.id
    ORDER BY zip
    SQL

    sql = ZipcodeRate.send(:sanitize_sql, [str, version_number])
    ZipcodeRate.connection.execute(sql)
  end

  def self.add_extension_campus_type(version_number)
    str = <<-SQL
    UPDATE institutions SET campus_type = 'E'
    FROM versions
      WHERE substring(institutions.facility_code, 3 , 1) = 'X'
        AND institutions.campus_type IS NULL
        AND versions.number = #{version_number}
        AND versions.id = institutions.version_id;
    SQL
    Institution.connection.update(str)
  end
# edu_programs.length_in_weeks is being used twice because
  # it is a short term fix to an issue that they aren't sure how we should fix
  def self.build_institution_programs(version_number)
    str = <<-SQL
      INSERT INTO institution_programs (
        program_type,
        description,
        full_time_undergraduate,
        graduate,
        full_time_modifier,
        length_in_hours,
        school_locale,
        provider_website,
        provider_email_address,
        phone_area_code,
        phone_number,
        student_vet_group,
        student_vet_group_website,
        vet_success_name,
        vet_success_email,
        vet_tec_program,
        tuition_amount,
        length_in_weeks,
        institution_id
      )
      SELECT
        program_type,
        description,
        full_time_undergraduate,
        graduate,
        full_time_modifier,
        length_in_weeks,
        school_locale,
        provider_website,
        provider_email_address,
        phone_area_code,
        phone_number,
        student_vet_group,
        student_vet_group_website,
        vet_success_name,
        vet_success_email,
        vet_tec_program,
        tuition_amount,
        length_in_weeks,
        i.id
      FROM programs p
        INNER JOIN edu_programs e ON p.facility_code = e.facility_code
          AND LOWER(description) = LOWER(vet_tec_program)
          AND vet_tec_program IS NOT NULL
        INNER JOIN institutions i ON p.facility_code = i.facility_code
        INNER JOIN versions v ON v.number = ?
        WHERE v.id = i.version_id
          AND i.approved = true;

      UPDATE institution_programs SET
        length_in_hours = 0,
        length_in_weeks = 0
      WHERE id IN (
        SELECT MIN(id) FROM institution_programs GROUP BY UPPER(description), institution_id HAVING COUNT(*) > 1
      );

      DELETE FROM institution_programs WHERE id NOT IN (
        SELECT MIN(id) FROM institution_programs GROUP BY UPPER(description), institution_id
      );
    SQL

    sql = InstitutionProgram.send(:sanitize_sql, [str, version_number])
    InstitutionProgram.connection.execute(sql)
  end

  def self.build_school_certifying_officials(version_number)
    str = <<-SQL
        INSERT INTO school_certifying_officials(
          facility_code,
          institution_name,
          priority,
          first_name,
          last_name,
          title,
          phone_area_code,
          phone_number,
          phone_extension,
          email,
          institution_id)
       SELECT DISTINCT
        s.facility_code,
        institution_name,
        priority,
        first_name,
        last_name,
        title,
        phone_area_code,
        phone_number,
        phone_extension,
        email,
        i.id
      FROM school_certifying_officials s
      INNER JOIN institutions i ON s.facility_code = i.facility_code
      INNER JOIN versions v ON v.number = ?
      WHERE v.id = i.version_id
      AND s.institution_id IS NOT NULL;
    SQL
    sql = SchoolCertifyingOfficial.send(:sanitize_sql, [str, version_number])
    SchoolCertifyingOfficial.connection.execute(sql)
  end

  def self.add_sco_institution_id(version_number)
    str = <<-SQL
        UPDATE school_certifying_officials s
        SET institution_id = i.id
        FROM institutions i
        INNER JOIN versions v ON v.number = ?
        WHERE s.facility_code = i.facility_code
        AND i.version_id = v.id
        AND s.institution_id IS NULL;
    SQL
    sql = SchoolCertifyingOfficial.send(:sanitize_sql, [str, version_number])
    SchoolCertifyingOfficial.connection.execute(sql)
  end

end

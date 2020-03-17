# frozen_string_literal: true

module InstitutionBuilder
  def self.columns_for_update(klass)
    table_name = klass.name.underscore.pluralize
    klass::COLS_USED_IN_INSTITUTION.map(&:to_s).map { |col| %("#{col}" = #{table_name}.#{col}) }.join(', ')
  end

  def self.run_insertions(version)
    initialize_with_weams(version)
    add_crosswalk(version.id)
    add_sva(version.id)
    add_vsoc(version.id)
    add_eight_key(version.id)
    add_accreditation(version.id)
    add_arf_gi_bill(version.id)
    add_p911_tf(version.id)
    add_p911_yr(version.id)
    add_mou(version.id)
    add_scorecard(version.id)
    add_ipeds_ic(version.id)
    add_ipeds_hd(version.id)
    add_ipeds_ic_ay(version.id)
    add_ipeds_ic_py(version.id)
    add_sec_702(version.id)
    add_settlement(version.id)
    add_hcm(version.id)
    add_complaint(version.id)
    add_outcome(version.id)
    add_stem_offered(version.id)
    add_yellow_ribbon_programs(version.id)
    add_school_closure(version.id)
    add_vet_tec_provider(version.id)
    add_extension_campus_type(version.id)
    add_sec109_closed_school(version.id)
    build_zip_code_rates_from_weams(version.number)
    build_institution_programs(version.id)
    build_versioned_school_certifying_official(version.id)
  end

  def self.run(user)
    error_msg = nil
    version = Version.create!(production: false, user: user)

    begin
      Institution.transaction do
        run_insertions(version)
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

  def self.initialize_with_weams(version)
    columns = Weam::COLS_USED_IN_INSTITUTION.map(&:to_s)
    timestamp = Time.now.utc.to_s(:db)
    conn = ApplicationRecord.connection

    str = "INSERT INTO institutions (#{columns.join(', ')}, version, created_at, updated_at, version_id) "
    str += Weam
           .select(columns)
           .select("#{version.number.to_i} as version")
           .select("#{conn.quote(timestamp)} as created_at")
           .select("#{conn.quote(timestamp)} as updated_at")
           .select('v.id as version_id')
           .to_sql
    str += "INNER JOIN versions v ON v.number = #{version.number}"
    Institution.connection.insert(str)

    # remove duplicates
    delete_str = <<-SQL
      DELETE FROM institutions WHERE id NOT IN (
        SELECT MIN(id) FROM institutions WHERE version_id = ? GROUP BY UPPER(facility_code)
      ) AND version_id = ?;
    SQL
    sql = InstitutionProgram.send(:sanitize_sql, [delete_str, version.id, version.id])

    Institution.connection.execute(sql)
  end

  def self.add_crosswalk(version_id)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(Crosswalk)}
      FROM crosswalks
      WHERE institutions.facility_code = crosswalks.facility_code
      AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  def self.add_sec109_closed_school(version_id)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(Sec109ClosedSchool)}
      FROM  sec109_closed_schools
      WHERE institutions.facility_code = sec109_closed_schools.facility_code
      AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  def self.add_sva(version_id)
    str = <<-SQL
      UPDATE institutions SET
        student_veteran = TRUE, student_veteran_link = svas.student_veteran_link
      FROM svas
      WHERE institutions.cross = svas.cross AND svas.cross IS NOT NULL
      AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  def self.add_vsoc(version_id)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(Vsoc)}
      FROM vsocs
      WHERE institutions.facility_code = vsocs.facility_code
      AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  def self.add_eight_key(version_id)
    str = <<-SQL
      UPDATE institutions SET eight_keys = TRUE
      FROM eight_keys
      WHERE institutions.cross = eight_keys.cross
        AND eight_keys.cross IS NOT NULL
        AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  # Set the `accreditation_type`, `accreditation_status`, and create `caution_flags` rows
  # by joining on
  # `ope6` for more broad match, then `ope` for a more specific match because not all institutions
  # have a unique `ope` provided.
  # Set the accreditation_type according to the hierarchy hybrid < national < regional
  # We include only those accreditation that are institutional and currently active.
  def self.add_accreditation(version_id)
    accreditation_join_clauses = [
      'institutions.ope6 = accreditation_institute_campuses.ope6',
      'institutions.ope = accreditation_institute_campuses.ope'
    ]

    # Set the `accreditation_type`
    str = <<-SQL
      UPDATE institutions SET
        accreditation_type = accreditation_records.accreditation_type
      FROM accreditation_institute_campuses, accreditation_records
      WHERE {{JOIN_CLAUSE}}
        AND accreditation_institute_campuses.dapip_id = accreditation_records.dapip_id
        AND institutions.ope IS NOT NULL
        AND accreditation_records.accreditation_end_date IS NULL
        AND accreditation_records.program_id = 1
        AND institutions.version_id = #{version_id}
        AND accreditation_records.accreditation_type = {{ACC_TYPE}};
    SQL
    accreditation_join_clauses.each do |join_clause|
      %w[hybrid national regional].each do |acc_type|
        Institution.connection.update(str.gsub('{{JOIN_CLAUSE}}', join_clause).gsub('{{ACC_TYPE}}', "'#{acc_type}'"))
      end
    end

    where_clause = <<-SQL
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
        -- has not received a restorative action after the probationary action
        AND (
          SELECT id from accreditation_actions
            WHERE action_description in (#{AccreditationAction::RESTORATIVE_STATUSES.join(', ')})
            AND dapip_id = aa.dapip_id
            AND program_id = 1
            AND action_date > aa.action_date
            LIMIT 1
        ) IS NULL
        AND institutions.ope IS NOT NULL
        AND institutions.version_id = #{version_id}
    SQL

    # Set the `accreditation_status`
    str = <<-SQL
      UPDATE institutions
      SET accreditation_status = aa.action_description
      FROM accreditation_institute_campuses, accreditation_actions aa
      #{where_clause}
    SQL

    accreditation_join_clauses.each do |join_clause|
      Institution.connection.update(str.gsub('{{JOIN_CLAUSE}}', join_clause))
    end

    # Create `caution_flags` rows
    caution_flag_reason = <<-SQL
      concat(aa.action_description, ' (', aa.justification_description, ')')
    SQL

    caution_flag_from_clause = <<-SQL
      FROM accreditation_institute_campuses, accreditation_actions aa, institutions
    SQL

    accreditation_join_clauses.each do |join_clause|
      build_caution_flags(version_id, CautionFlag::SOURCES[:accreditation_action],
                          caution_flag_reason,
                          caution_flag_from_clause,
                          where_clause.gsub('{{JOIN_CLAUSE}}', join_clause))
    end
  end

  def self.add_arf_gi_bill(version_id)
    str = <<-SQL
      UPDATE institutions SET gibill = arf_gi_bills.gibill
      FROM arf_gi_bills
      WHERE institutions.facility_code = arf_gi_bills.facility_code
      AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  def self.add_p911_tf(version_id)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(P911Tf)}
      FROM p911_tfs
      WHERE institutions.facility_code = p911_tfs.facility_code
      AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  def self.add_p911_yr(version_id)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(P911Yr)}
      FROM p911_yrs
      WHERE institutions.facility_code = p911_yrs.facility_code
      AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  def self.add_mou(version_id)
    # Sets the dodmou for any approved school having a probation or title IV non-compliance status.
    str = <<-SQL
      UPDATE institutions SET
        dodmou = mous.dodmou
      FROM mous
      WHERE institutions.ope6 = mous.ope6
      AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)

    # The caution flag reason is only affected by a DoD type probation status
    reason = <<-SQL
      'DoD Probation For Military Tuition Assistance'
    SQL
    caution_flag_from_clause = <<-SQL
      FROM institutions, (
        SELECT distinct(ope6) FROM mous
        WHERE dod_status = TRUE
      ) as reasons_list
    SQL
    caution_flag_where_clause = <<-SQL
      WHERE institutions.ope6 = reasons_list.ope6
      AND institutions.version_id = #{version_id}
    SQL

    # Create `caution_flags` rows
    build_caution_flags(version_id, CautionFlag::SOURCES[:mou],
                        reason, caution_flag_from_clause, caution_flag_where_clause)
  end

  def self.add_scorecard(version_id)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(Scorecard)}
      FROM scorecards
      WHERE institutions.cross = scorecards.cross
      AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_ic(version_id)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(IpedsIc)}
      FROM ipeds_ics
      WHERE institutions.cross = ipeds_ics.cross
      AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_hd(version_id)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(IpedsHd)}
      FROM ipeds_hds
      WHERE institutions.cross = ipeds_hds.cross
      AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_ic_ay(version_id)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(IpedsIcAy)}
      FROM ipeds_ic_ays
      WHERE institutions.cross = ipeds_ic_ays.cross
      AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  def self.add_ipeds_ic_py(version_id)
    columns = IpedsIcPy::COLS_USED_IN_INSTITUTION.map(&:to_s).map do |col|
      %("#{col}" = CASE WHEN institutions.#{col} IS NULL THEN ipeds_ic_pies.#{col} ELSE institutions.#{col} END)
    end.join(', ')

    str = <<-SQL
      UPDATE institutions SET #{columns}
      FROM ipeds_ic_pies
      WHERE institutions.cross = ipeds_ic_pies.cross
      AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  # When overlapping, sec_702 data from sec702_schools has precedence over data from sec702_schools, and
  # only approved public schools can be SEC 702 complaint
  def self.add_sec_702(version_id)
    s702_list = <<-SQL
    (SELECT facility_code, sec702s.sec_702 FROM institutions
          INNER JOIN sec702s ON sec702s.state = institutions.state
            EXCEPT SELECT facility_code, sec_702 FROM sec702_schools
            UNION SELECT facility_code, sec_702 FROM sec702_schools
      ) AS s702_list
    SQL
    where_clause = <<-SQL
      WHERE institutions.facility_code = s702_list.facility_code
        AND institutions.institution_type_name = 'PUBLIC'
        AND institutions.version_id = #{version_id}
    SQL

    str = <<-SQL
      UPDATE institutions SET sec_702 = s702_list.sec_702
      FROM #{s702_list}
      #{where_clause}
    SQL

    Institution.connection.update(str)

    reason = <<-SQL
      'Does Not Offer Required In-State Tuition Rates'
    SQL
    caution_flag_from_clause = <<-SQL
      FROM institutions, #{s702_list}
    SQL
    caution_flag_where_clause = <<-SQL
      #{where_clause}
      AND NOT s702_list.sec_702
    SQL

    # Create `caution_flags` rows
    build_caution_flags(version_id, CautionFlag::SOURCES[:sec_702],
                        reason, caution_flag_from_clause, caution_flag_where_clause)
  end

  # Sets caution flags and caution flag reasons if the corresponding approved school (by IPEDs id)
  # has an entry in the settlements table.
  def self.add_settlement(version_id)
    reason = <<-SQL
      settlement_list.descriptions
    SQL
    caution_flag_from_clause = <<-SQL
      FROM institutions, (
        SELECT "cross", array_to_string(array_agg(distinct(settlement_description)), ', ') AS descriptions
        FROM settlements
        WHERE "cross" IS NOT NULL
        GROUP BY "cross"
      ) settlement_list
    SQL
    caution_flag_where_clause = <<-SQL
      WHERE institutions.cross = settlement_list.cross
      AND institutions.version_id = #{version_id}
    SQL

    # Create `caution_flags` rows
    build_caution_flags(version_id, CautionFlag::SOURCES[:settlement],
                        reason, caution_flag_from_clause, caution_flag_where_clause)
  end

  # Sets caution flags and caution flag reasons if the corresponding approved school (by ope6)
  # has an entry in the hcms table.
  def self.add_hcm(version_id)
    reason = <<-SQL
      hcm_list.reasons
    SQL
    caution_flag_from_clause = <<-SQL
      FROM institutions, (
        SELECT "ope6",
          array_to_string(array_agg(distinct('Heightened Cash Monitoring (' || hcm_reason || ')')), ', ') AS reasons
        FROM hcms
        GROUP BY ope6
      ) hcm_list
    SQL
    caution_flag_where_clause = <<-SQL
      WHERE institutions.ope6 = hcm_list.ope6
      AND institutions.version_id = #{version_id}
    SQL

    # Create `caution_flags` rows
    build_caution_flags(version_id, CautionFlag::SOURCES[:hcm],
                        reason, caution_flag_from_clause, caution_flag_where_clause)
  end

  def self.add_complaint(version_id)
    Complaint.update_ope_from_crosswalk
    Complaint.rollup_sums(:facility_code, version_id)
    Complaint.rollup_sums(:ope6, version_id)
  end

  def self.add_outcome(version_id)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(Outcome)}
      FROM outcomes
      WHERE institutions.facility_code = outcomes.facility_code
      AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  def self.add_stem_offered(version_id)
    str = <<-SQL
      UPDATE institutions SET stem_offered=true
      FROM ipeds_cip_codes, stem_cip_codes
      WHERE institutions.cross = ipeds_cip_codes.cross
        AND institutions.cross IS NOT NULL
        AND ipeds_cip_codes.ctotalt > 0
        AND ipeds_cip_codes.cipcode = stem_cip_codes.twentyten_cip_code
        AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  def self.add_yellow_ribbon_programs(version_id)
    str = <<-SQL
      INSERT INTO yellow_ribbon_programs
        (version, institution_id, degree_level, division_professional_school,
          number_of_students, contribution_amount, amendment_date, campus,
          city, consolidated_agreement, date_agreement_received,
          date_confirmation_sent, date_yr_signed_by_yr_official, facility_code,
          flight_school, ineligible, initials_yr_processor, missed_deadline,
          modified, new_school, notes, open_ended_agreement, public_private,
          school_name_in_weams, school_name_in_yr_database, sco_email_address,
          sco_name, sco_telephone_number, sfr_email_address, sfr_name,
          sfr_telephone_number, state, street_address, updated_for_2011_2012,
          withdrawn, year_of_yr_participation, zip, created_at, updated_at)
        (SELECT
          i.version, i.id, yrs.degree_level, yrs.division_professional_school,
            yrs.number_of_students, yrs.contribution_amount,
            yrs.amendment_date, yrs.campus, yrs.city,
            yrs.consolidated_agreement, yrs.date_agreement_received,
            yrs.date_confirmation_sent, yrs.date_yr_signed_by_yr_official,
            yrs.facility_code, yrs.flight_school, yrs.ineligible,
            yrs.initials_yr_processor, yrs.missed_deadline, yrs.modified,
            yrs.new_school, yrs.notes, yrs.open_ended_agreement,
            yrs.public_private, yrs.school_name_in_weams,
            yrs.school_name_in_yr_database, yrs.sco_email_address, yrs.sco_name,
            yrs.sco_telephone_number, yrs.sfr_email_address, yrs.sfr_name,
            yrs.sfr_telephone_number, yrs.state, yrs.street_address,
            yrs.updated_for_2011_2012, yrs.withdrawn, yrs.year_of_yr_participation,
            yrs.zip, NOW(), NOW()
          FROM institutions as i
          INNER JOIN yellow_ribbon_program_sources as yrs
          ON i.facility_code = yrs.facility_code
          WHERE i.version_id = #{version_id}
        )
    SQL

    sql = Institution.send(:sanitize_sql, [str])
    Institution.connection.execute(sql)
  end

  def self.add_school_closure(version_id)
    str = <<-SQL
      UPDATE institutions SET #{columns_for_update(SchoolClosure)}
      FROM school_closures
      WHERE institutions.facility_code = school_closures.facility_code
      AND institutions.version_id = #{version_id}
    SQL

    Institution.connection.update(str)
  end

  def self.add_vet_tec_provider(version_id)
    str = <<-SQL
    UPDATE institutions SET vet_tec_provider = TRUE
      from versions
      WHERE substring(institutions.facility_code, 2 , 1) = 'V'
      AND institutions.version_id = #{version_id}
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

  def self.add_extension_campus_type(version_id)
    str = <<-SQL
    UPDATE institutions SET campus_type = 'E'
    FROM versions
      WHERE substring(institutions.facility_code, 3 , 1) = 'X'
        AND institutions.campus_type IS NULL
        AND institutions.version_id = #{version_id}
    SQL
    Institution.connection.update(str)
  end

  # edu_programs.length_in_weeks is being used twice because
  # it is a short term fix to an issue that they aren't sure how we should fix
  def self.build_institution_programs(version_id)
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
        WHERE i.version_id = #{version_id}
          AND i.approved = true;;

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

    sql = InstitutionProgram.send(:sanitize_sql, [str])
    InstitutionProgram.connection.execute(sql)
  end

  def self.build_versioned_school_certifying_official(version_id)
    str = <<-SQL
      INSERT INTO versioned_school_certifying_officials(
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
      Select
        i.facility_code,
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
      INNER JOIN institutions i ON i.facility_code = s.facility_code
      WHERE i.version_id = #{version_id}
    SQL

    sql = SchoolCertifyingOfficial.send(:sanitize_sql, [str])
    SchoolCertifyingOfficial.connection.execute(sql)
  end

  # Creates caution flags
  # Expects `reason_sql`, `from_sql`, and `where_sql` to be a multiline SQL string
  def self.build_caution_flags(version_id, source, reason_sql, from_sql, where_sql)
    timestamp = Time.now.utc.to_s(:db)
    conn = ApplicationRecord.connection

    str = <<-SQL
      INSERT INTO caution_flags (institution_id, version_id, source, reason, created_at, updated_at)
      SELECT institutions.id,
              #{version_id} as version_id,
              '#{source}' as source,
              #{reason_sql} as reason,
              #{conn.quote(timestamp)} as created_at,
              #{conn.quote(timestamp)} as updated_at
        #{from_sql}
        #{where_sql}
    SQL
    sql = CautionFlag.send(:sanitize_sql, [str])
    CautionFlag.connection.execute(sql)
  end
end

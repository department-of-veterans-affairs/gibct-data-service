# frozen_string_literal: true

module InstitutionBuilder
  module Common
    def columns_for_update(klass)
      table_name = klass.name.underscore.pluralize
      klass::COLS_USED_IN_INSTITUTION.map(&:to_s).map { |col| %("#{col}" = #{table_name}.#{col}) }.join(', ')
    end

    def add_columns_for_update(version_id, klass, where_clause)
      str = <<-SQL
        UPDATE institutions SET #{columns_for_update(klass)}
        FROM #{klass.table_name}
        WHERE #{where_clause}
        AND institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(str)
    end
  end

  def self.run(user)
    Factory.run(user)
  end

  class Factory
    extend Common

    def self.run_insertions(version)
      initialize_with_weams(version)
      add_crosswalk(version.id)
      add_sec103(version.id)
      add_sva(version.id)
      add_vsoc(version.id)
      add_eight_key(version.id)
      add_accreditation(version.id)
      add_arf_gi_bill(version.id)
      add_post_911_stats(version.id)
      add_mou(version.id)
      ScorecardBuilder.build(version.id)
      IpedsBuilder.build_ic(version.id)
      IpedsBuilder.build_hd(version.id)
      IpedsBuilder.build_ic_ay(version.id)
      IpedsBuilder.build_ic_py(version.id)
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
      build_zip_code_rates_from_weams(version.id)
      build_institution_programs(version.id)
      build_versioned_school_certifying_official(version.id)
      ScorecardBuilder.add_lat_lon_from_scorecard(version.id)
      add_provider_type(version.id)
      VrrapBuilder.build(version.id)
    end

    def self.build_ratings(version)
      build_institution_category_ratings(version.id)
    end

    def self.run(user)
      error_msg = nil
      version = Version.create!(production: false, user: user)
      begin
        Institution.transaction do
          run_insertions(version)
        end

        Institution.transaction do
          build_ratings(version)
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
        institutions.facility_code = crosswalks.facility_code
      SQL
      add_columns_for_update(version_id, Crosswalk, str)
    end

    def self.add_sec109_closed_school(version_id)
      str = <<-SQL
        institutions.facility_code = sec109_closed_schools.facility_code
      SQL

      add_columns_for_update(version_id, Sec109ClosedSchool, str)
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
        institutions.facility_code = vsocs.facility_code
      SQL
      add_columns_for_update(version_id, Vsoc, str)
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
    # by joining on `ope` for a specific match
    # Set the accreditation_type according to the hierarchy hybrid < national < regional
    # We include only those accreditation that are institutional and currently active.
    #
    # Updating caution_flag and caution_flag_reason are needed for usage by the link
    # "Download Data on All Schools (Excel)" at https://www.va.gov/gi-bill-comparison-tool/
    def self.add_accreditation(version_id)
      # Set the `accreditation_type`
      str = <<-SQL
        UPDATE institutions SET
          accreditation_type = accreditation_records.accreditation_type
        FROM accreditation_institute_campuses, accreditation_records
        WHERE institutions.ope = accreditation_institute_campuses.ope
          AND accreditation_institute_campuses.dapip_id = accreditation_records.dapip_id
          AND institutions.ope IS NOT NULL
          AND accreditation_records.accreditation_end_date IS NULL
          AND accreditation_records.program_id = 1
          AND institutions.version_id = #{version_id}
          AND accreditation_records.accreditation_type = {{ACC_TYPE}};
      SQL

      %w[hybrid national regional].each do |acc_type|
        Institution.connection.update(str.gsub('{{ACC_TYPE}}', "'#{acc_type}'"))
      end

      where_clause = <<-SQL
          WHERE institutions.ope = accreditation_institute_campuses.ope
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
        SET accreditation_status = aa.action_description,
            caution_flag = TRUE,
            caution_flag_reason = concat(aa.action_description, ' (', aa.justification_description, ')')
        FROM accreditation_institute_campuses, accreditation_actions aa
        #{where_clause}
      SQL

      Institution.connection.update(str)

      # Create `caution_flags` rows
      caution_flag_clause = <<-SQL
        FROM accreditation_institute_campuses, accreditation_actions aa, institutions
        #{where_clause}
      SQL

      CautionFlag.build(version_id, AccreditationCautionFlag, caution_flag_clause)
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

    def self.add_post_911_stats(version_id)
      str = <<-SQL
        UPDATE institutions SET
          p911_recipients = tuition_and_fee_count,
          p911_tuition_fees = tuition_and_fee_total_amount,
          p911_yr_recipients = yellow_ribbon_count,
          p911_yellow_ribbon = yellow_ribbon_total_amount
        FROM post911_stats
        WHERE institutions.facility_code = post911_stats.facility_code
        AND institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(str)
    end

    # Sets the dodmou for any approved school having a probation or title IV non-compliance status.
    #
    # Updating caution_flag and caution_flag_reason are needed for usage by the link
    # "Download Data on All Schools (Excel)" at https://www.va.gov/gi-bill-comparison-tool/
    def self.add_mou(version_id)
      str = <<-SQL
        UPDATE institutions SET
          dodmou = mous.dodmou,
          caution_flag = CASE WHEN mous.dod_status = TRUE THEN TRUE ELSE caution_flag END
        FROM mous
        WHERE institutions.ope = mous.ope
        AND institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(str)

      str = <<-SQL
        UPDATE institutions SET
          caution_flag_reason = concat_ws(', ', caution_flag_reason, reasons_list.reason)
        FROM (
          SELECT distinct(ope), 'DoD Probation For Military Tuition Assistance' AS reason FROM mous
          WHERE dod_status = TRUE) as reasons_list
        WHERE institutions.ope = reasons_list.ope
        AND institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(str)

      caution_flag_clause = <<-SQL
        FROM institutions, (
          SELECT distinct(ope) FROM mous
          WHERE dod_status = TRUE
        ) as reasons_list
        WHERE institutions.ope = reasons_list.ope
        AND institutions.version_id = #{version_id}
      SQL

      CautionFlag.build(version_id, MouCautionFlag, caution_flag_clause)
    end

    # Updates institution table as well as creates caution_flags
    # for institutions that are not sec702
    #
    # if va_caution_flags contains the institutions facility_code
    #     then set institution.sec702 to value from va_caution_flags
    # else check the institution's state value in sec702s
    #     then set institution.sec702 to value from sec702s
    #
    # A true value indicates institution is sec702 complaint
    #
    # Updating caution_flag and caution_flag_reason are needed for usage by the link
    # "Download Data on All Schools (Excel)" at https://www.va.gov/gi-bill-comparison-tool/
    def self.add_sec_702(version_id)
      where_conditions = <<-SQL
          AND institutions.institution_type_name = 'PUBLIC'
          AND institutions.version_id = #{version_id}
      SQL

      str = <<-SQL
        UPDATE institutions SET
          sec_702 = s702_list.sec702_compliant,
          caution_flag = (NOT s702_list.sec702_compliant) OR caution_flag,
          caution_flag_reason = CASE WHEN NOT s702_list.sec702_compliant
            THEN concat_ws(', ', caution_flag_reason, 'Does Not Offer Required In-State Tuition Rates')
            ELSE caution_flag_reason
          END
        FROM (
          SELECT institutions.facility_code,
          CASE WHEN va_caution_flags.sec_702 IS NULL THEN sec702s.sec_702
              ELSE va_caution_flags.sec_702 END AS sec702_compliant
          FROM institutions
            LEFT JOIN va_caution_flags ON institutions.facility_code = va_caution_flags.facility_code
            LEFT JOIN sec702s ON institutions.state = sec702s.state
        ) AS s702_list
        WHERE institutions.facility_code = s702_list.facility_code
        #{where_conditions}
      SQL

      Institution.connection.update(str)

      caution_flag_clause = <<-SQL
        FROM institutions
        WHERE NOT institutions.sec_702
        #{where_conditions}
      SQL

      CautionFlag.build(version_id, Sec702CautionFlag, caution_flag_clause)
    end

    # Sets caution flags and caution flag reasons if the corresponding approved school (by IPEDs id)
    # has an entry in the settlements table.
    #
    # Updating caution_flag and caution_flag_reason are needed for usage by the link
    # "Download Data on All Schools (Excel)" at https://www.va.gov/gi-bill-comparison-tool/
    def self.add_settlement(version_id)
      # Update institutions table for "Download Data on All Schools (Excel)"
      # Update all institutions without an IPEDs value
      str = <<-SQL
        UPDATE institutions SET
          caution_flag = TRUE,
          caution_flag_reason = concat_ws(', ', caution_flag_reason, vcf_list.titles)
        FROM (
          SELECT facility_code,
              array_to_string(array_agg(distinct(settlement_title)), ',') as titles
            FROM va_caution_flags
            WHERE settlement_title IS NOT NULL
              AND settlement_description IS NOT NULL
            GROUP BY facility_code
        ) vcf_list
        WHERE institutions.facility_code = vcf_list.facility_code
        AND institutions.cross IS NULL
        AND institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(str)

      # Update all institutions with an IPEDs value
      str = <<-SQL
        UPDATE institutions SET
          caution_flag = TRUE,
          caution_flag_reason = concat_ws(', ', caution_flag_reason, ipeds_list.titles)
        FROM (
          SELECT "cross" as ipeds, array_to_string(array_agg(distinct(settlement_title)), ',') as titles
            FROM institutions JOIN va_caution_flags ON institutions.facility_code = va_caution_flags.facility_code
            WHERE settlement_title IS NOT NULL
              AND settlement_description IS NOT NULL
              AND "cross" IS NOT NULL
            GROUP BY "cross"
        ) ipeds_list
        WHERE institutions.cross = ipeds_list.ipeds
        AND institutions.cross IS NOT NULL
        AND institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(str)

      # Create Caution Flags
      timestamp = Time.now.utc.to_s(:db)
      conn = ApplicationRecord.connection
      insert_columns = %i[
        institution_id version_id source title description
        link_text link_url flag_date created_at updated_at
      ]

      link_text = <<-SQL
        CASE WHEN va_caution_flags.settlement_link IS NOT NULL
          THEN 'Learn more about this cautionary warning'
          ELSE null end
      SQL

      flag_date_sql = <<-SQL
        CASE WHEN va_caution_flags.settlement_date IS NOT NULL
          THEN TO_DATE(va_caution_flags.settlement_date, 'MM/DD/YY')
          ELSE null END
      SQL

      # Update all institutions without an IPEDs value
      str = <<-SQL
            INSERT INTO caution_flags (#{insert_columns.join(' , ')})
            SELECT institutions.id,
                #{version_id} as version_id,
                'Settlement' as source,
                va_caution_flags.settlement_title as title,
                va_caution_flags.settlement_description as description,
                #{link_text} as link_text,
                va_caution_flags.settlement_link as link_url,
                #{flag_date_sql} as flag_date,
                #{conn.quote(timestamp)} as created_at,
                #{conn.quote(timestamp)} as updated_at
            FROM institutions JOIN va_caution_flags
              ON institutions.facility_code = va_caution_flags.facility_code
            WHERE institutions.version_id = #{version_id}
              AND va_caution_flags.settlement_title IS NOT NULL
              AND va_caution_flags.settlement_description IS NOT NULL
              AND institutions.cross IS NULL
      SQL

      sql = CautionFlag.send(:sanitize_sql, [str])
      CautionFlag.connection.execute(sql)

      # Update all institutions with an IPEDs value
      str = <<-SQL
            INSERT INTO caution_flags (#{insert_columns.join(' , ')})
            SELECT institutions.id,
                #{version_id} as version_id,
                'Settlement' as source,
                va_caution_flags.settlement_title as title,
                va_caution_flags.settlement_description as description,
                #{link_text} as link_text,
                va_caution_flags.settlement_link as link_url,
                #{flag_date_sql} as flag_date,
                #{conn.quote(timestamp)} as created_at,
                #{conn.quote(timestamp)} as updated_at
            FROM institutions JOIN (
              SELECT "cross" as ipeds, settlement_title, settlement_description, settlement_date, settlement_link
              FROM institutions JOIN va_caution_flags ON institutions.facility_code = va_caution_flags.facility_code
              WHERE settlement_title IS NOT NULL
                AND settlement_description IS NOT NULL
                AND "cross" IS NOT NULL
              GROUP BY "cross", settlement_title, settlement_description, settlement_date, settlement_link
            ) va_caution_flags
              ON institutions.cross = va_caution_flags.ipeds
            WHERE institutions.version_id = #{version_id}
              AND va_caution_flags.settlement_title IS NOT NULL
              AND va_caution_flags.settlement_description IS NOT NULL
              AND institutions.cross IS NOT NULL
      SQL

      sql = CautionFlag.send(:sanitize_sql, [str])
      CautionFlag.connection.execute(sql)
    end

    # Sets caution flags and caution flag reasons if the corresponding approved school by ope
    # has an entry in the hcms table.
    #
    # Updating caution_flag and caution_flag_reason are needed for usage by the link
    # "Download Data on All Schools (Excel)" at https://www.va.gov/gi-bill-comparison-tool/
    def self.add_hcm(version_id)
      hcm_list = <<-SQL
        (SELECT ope,
            array_to_string(array_agg(distinct('Heightened Cash Monitoring (' || hcm_reason || ')')), ', ') AS reasons
          FROM hcms
          GROUP BY ope
        ) hcm_list
      SQL

      str = <<-SQL
        UPDATE institutions SET
          caution_flag = TRUE,
          caution_flag_reason = concat_ws(', ', caution_flag_reason, hcm_list.reasons)
        FROM #{hcm_list}
        WHERE institutions.ope = hcm_list.ope
        AND institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(str)

      caution_flag_clause = <<-SQL
        FROM institutions, #{hcm_list}
        WHERE institutions.ope = hcm_list.ope
        AND institutions.version_id = #{version_id}
      SQL

      CautionFlag.build(version_id, HcmCautionFlag, caution_flag_clause)
    end

    def self.add_complaint(version_id)
      Complaint.update_ope_from_crosswalk
      Complaint.rollup_sums(:facility_code, version_id)
      Complaint.rollup_sums(:ope6, version_id)
    end

    def self.add_outcome(version_id)
      str = <<-SQL
        institutions.facility_code = outcomes.facility_code
      SQL
      add_columns_for_update(version_id, Outcome, str)
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
        UPDATE institutions SET
          school_closing = TRUE,
          school_closing_on = TO_DATE(va_caution_flags.school_closing_date, 'MM/DD/YYYY')
        FROM va_caution_flags
        WHERE institutions.facility_code = va_caution_flags.facility_code
        AND va_caution_flags.school_closing_date IS NOT NULL
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

    def self.build_zip_code_rates_from_weams(version_id)
      timestamp = Time.now.utc.to_s(:db)
      conn = ApplicationRecord.connection

      str = <<-SQL
      INSERT INTO zipcode_rates (
        zip_code,
        mha_rate_grandfathered,
        mha_rate,
        mha_name,
        created_at,
        updated_at,
        version_id
      )
      SELECT
        zip,
        bah,
        dod_bah,
        concat_ws(', ', physical_city, physical_state) as physical_location,
        #{conn.quote(timestamp)},
        #{conn.quote(timestamp)},
        #{version_id}
        FROM weams
      WHERE country = 'USA'
        AND bah IS NOT null
        AND dod_bah IS NOT null
      GROUP BY zip, bah, dod_bah, physical_location
      ORDER BY zip
      SQL

      sql = ZipcodeRate.send(:sanitize_sql, [str])
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

    def self.add_sec103(version_id)
      ihl_prefixes = Institution::IHL_FACILITY_CODE_PREFIXES.map { |prefix| "'#{prefix}'" }.join(', ')
      str = <<-SQL
        -- set default message for IHL institutions
        UPDATE institutions SET section_103_message = '#{Institution::DEFAULT_IHL_SECTION_103_MESSAGE}'
        FROM weams
        WHERE weams.facility_code = institutions.facility_code
          AND SUBSTRING(weams.facility_code, 1, 2) IN(#{ihl_prefixes})
          AND institutions.version_id = #{version_id};

        -- set message based on sec103s
        UPDATE institutions SET #{columns_for_update(Sec103)},
          section_103_message = CASE
            WHEN sec103s.complies_with_sec_103 = true AND sec103s.solely_requires_coe = false
              AND (sec103s.requires_coe_and_criteria = true OR sec103s.requires_coe_and_criteria IS NULL) THEN
              'Requires Certificate of Eligibility (COE) and additional criteria'
            WHEN sec103s.complies_with_sec_103 = true AND sec103s.solely_requires_coe = true THEN
              'Requires Certificate of Eligibility (COE)'
            ELSE institutions.section_103_message END,
          approved = CASE
            WHEN sec103s.complies_with_sec_103 = false THEN FALSE
            ELSE institutions.approved END
        FROM sec103s INNER JOIN weams ON weams.facility_code = sec103s.facility_code
            AND SUBSTRING(weams.facility_code, 1, 2) IN(#{ihl_prefixes})
        WHERE institutions.facility_code = sec103s.facility_code AND institutions.version_id = #{version_id};
      SQL

      Institution.connection.execute(InstitutionProgram.send(:sanitize_sql, [str]))
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
      valid_priorities = SchoolCertifyingOfficial::VALID_PRIORITY_VALUES.map { |value| "'#{value}'" }.join(', ')
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
        WHERE i.version_id = #{version_id} AND UPPER(s.priority) IN(#{valid_priorities})
      SQL

      sql = SchoolCertifyingOfficial.send(:sanitize_sql, [str])
      SchoolCertifyingOfficial.connection.execute(sql)
    end

    def self.build_institution_category_ratings_for_category(version_id, category)
      sql = <<-SQL
        INSERT INTO institution_category_ratings (
          institution_id,
          category_name,
          rated1_count,
          rated2_count,
          rated3_count,
          rated4_count,
          rated5_count,
          na_count,
          average_rating,
          total_count
        )
        SELECT
          institutions.id,
          '#{category}',
          SUM(CASE #{category} WHEN 1 THEN 1 ELSE 0 END),
          SUM(CASE #{category} WHEN 2 THEN 1 ELSE 0 END),
          SUM(CASE #{category} WHEN 3 THEN 1 ELSE 0 END),
          SUM(CASE #{category} WHEN 4 THEN 1 ELSE 0 END),
          SUM(CASE #{category} WHEN 5 THEN 1 ELSE 0 END),
          SUM(CASE WHEN #{category} IS NULL THEN 1 ELSE 0 END),
          CASE
            WHEN COUNT(#{category}) = 0 THEN NULL
          ELSE
          (SUM(CASE #{category} WHEN 1 THEN 1 ELSE 0 END)
           + SUM(CASE #{category} WHEN 2 THEN 2 ELSE 0 END)
           + SUM(CASE #{category} WHEN 3 THEN 3 ELSE 0 END)
           + SUM(CASE #{category} WHEN 4 THEN 4 ELSE 0 END)
           + SUM(CASE #{category} WHEN 5 THEN 5 ELSE 0 END)) / COUNT(#{category})::float
          END,
          COUNT(#{category})
        FROM institutions
          INNER JOIN
          (
            SELECT
              facility_code vote_facility_code,
              #{category},
              row_num
            FROM
              (
                SELECT
                  facility_code,
                  CASE
                    WHEN #{category} <= 0 THEN null
                    WHEN #{category} > 5 THEN 5
                    ELSE #{category}
                  END,
                  ROW_NUMBER() OVER (PARTITION BY rater_id ORDER BY rated_at DESC ) AS row_num
                FROM school_ratings
              ) top_votes
            WHERE row_num = 1
          ) votes ON institutions.facility_code = vote_facility_code
        WHERE version_id = #{version_id}
        GROUP BY institutions.id
      SQL

      InstitutionCategoryRating.connection.execute(InstitutionCategoryRating.send(:sanitize_sql_for_conditions, [sql]))
    end

    def self.build_institution_category_ratings(version_id)
      InstitutionCategoryRating::RATING_CATEGORY_COLUMNS.each do |category_column|
        build_institution_category_ratings_for_category(version_id, category_column)
      end

      sql = <<-SQL
        UPDATE institutions
        SET rating_average = ratings.average, rating_count = ratings.count
        FROM(
          SELECT
            institution_id,
            CASE
              WHEN SUM(rated5_count) + SUM(rated4_count) + SUM(rated3_count)
                + SUM(rated2_count) + SUM(rated1_count) = 0 THEN NULL::float
            ELSE
            (SUM(rated5_count) * 5 + SUM(rated4_count) * 4 + SUM(rated3_count) * 3
              + SUM(rated2_count) * 2 + SUM(rated1_count))
              / (SUM(rated5_count) + SUM(rated4_count) + SUM(rated3_count)
              + SUM(rated2_count) + SUM(rated1_count))::float
            END average,
            COUNT(DISTINCT rater_id) count
          FROM institution_category_ratings
            INNER JOIN institutions ON institution_category_ratings.institution_id = institutions.id
              AND institutions.version_id = #{version_id}
            INNER JOIN school_ratings ON institutions.facility_code = school_ratings.facility_code
          group by institution_id
        ) ratings
        WHERE id = ratings.institution_id
        AND version_id = #{version_id}
      SQL

      Institution.connection.update(sql)
    end

    def self.add_provider_type(version_id)
      str = <<-SQL
        UPDATE institutions SET
          school_provider = CASE WHEN institution_type_name IN (:schools) AND vet_tec_provider IS FALSE THEN TRUE ELSE FALSE END,
          employer_provider = CASE WHEN institution_type_name = :employer AND vet_tec_provider IS FALSE THEN TRUE ELSE FALSE END
        WHERE institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(Institution.sanitize_sql_for_conditions([str,
                                                                             employer: Institution::EMPLOYER,
                                                                             schools: Institution::SCHOOLS]))
    end
  end
end

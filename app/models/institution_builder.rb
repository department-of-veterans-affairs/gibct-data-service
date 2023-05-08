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
      build_messages = {}
      initialize_with_weams(version)
      add_crosswalk(version.id)
      add_sec103(version.id)
      add_sva(version.id)
      add_owner(version.id)
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
      SuspendedCautionFlags.build(version.id)
      add_provider_type(version.id)
      VrrapBuilder.build(version.id)

      rate_institutions(version.id) if
        ENV['DEPLOYMENT_ENV'].eql?('vagov-dev') || ENV['DEPLOYMENT_ENV'].eql?('vagov-staging')

      unless initial_buildout?
        update_longitude_and_latitude(version.id)
        update_ungeocodable(version.id)
        geocode_institutions(version)
      end
      geocode_using_csv_file if initial_buildout?

      build_messages.filter { |_k, v| v.present? }
    end

    def self.run(user)
      prev_gen_start = Time.now.utc
      version = Version.create!(production: false, user: user)
      build_messages = {}
      begin
        Institution.transaction do
          if staging?
            # Skipping validation here because of the scale of this query (it will timeout updating all 70k records)
            # rubocop:disable Rails/SkipsModelValidations
            Institution.in_batches.update_all(
              accredited: nil,
              accreditation_type: nil,
              accreditation_status: nil,
              caution_flag: nil,
              caution_flag_reason: nil
            )
            # rubocop:enable Rails/SkipsModelValidations
          end
          build_messages = run_insertions(version)
        end

        # Clean up any existing unstaged previews
        prior_preview_ids = Version.prior_preview_ids
        delete_prior_preview_data(prior_preview_ids) if prior_preview_ids
        log_info_status 'Preview generated. Now publishing..'
        version.update(production: true, completed_at: Time.now.utc.to_s(:db))

        if production?
          # Build Sitemap and notify search engines in production only
          ping = request.original_url.include?(GibctSiteMapper::PRODUCTION_HOST)
          GibctSiteMapper.new(ping: ping)
        end
        Archiver.archive_previous_versions if Settings.archiver.archive
        log_info_status 'Preview generated and published'
      rescue ActiveRecord::StatementInvalid => e
        notice = 'There was an error occurring at the database level'
        log_info_status notice
        error_msg = e.message
        Rails.logger.error "#{notice}: #{error_msg}"
        version.delete
      rescue StandardError => e
        notice = 'There was an error of unexpected origin'
        log_info_status notice
        error_msg = e.message
        Rails.logger.error "#{notice}: #{error_msg}"
        version.delete
      end
      prev_gen_end = Time.now.utc

      Rails.logger.info "\n\n\n"
      Rails.logger.info "*** Preview Generation Beg: #{prev_gen_start}"
      Rails.logger.info "*** Preview Generation End: #{prev_gen_end}\n\n\n"
    end

    def self.initialize_with_weams(version)
      log_info_status 'Starting creation of base Institution rows'

      columns = Weam::COLS_USED_IN_INSTITUTION.map(&:to_s)
      timestamp = Time.now.utc.to_s(:db)
      conn = ApplicationRecord.connection

      str = "INSERT INTO institutions (#{columns.join(', ')}, version, created_at, updated_at, version_id) "
      str += Weam
             .select(columns)
             .select("#{version.number.to_i} as version")
             .select("#{version.number.to_i} as version")
             .select("#{conn.quote(timestamp)} as created_at")
             .select("#{conn.quote(timestamp)} as updated_at")
             .select('v.id as version_id')
             .to_sql
      str += "INNER JOIN versions v ON v.number = #{version.number}"

      Institution.connection.insert(str) # rubocop:disable Rails/SkipsModelValidations
      log_info_status 'Deleting duplicates'

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
      log_info_status 'Updating Crosswalk information'

      str = <<-SQL
        institutions.facility_code = crosswalks.facility_code
      SQL
      add_columns_for_update(version_id, Crosswalk, str)

      log_info_status 'Complete'
    end

    def self.add_sec109_closed_school(version_id)
      log_info_status 'Updating Sec109 information'

      str = <<-SQL
        institutions.facility_code = sec109_closed_schools.facility_code
      SQL

      add_columns_for_update(version_id, Sec109ClosedSchool, str)
    end

    def self.add_sva(version_id)
      log_info_status 'Updating SVA information'

      str = <<-SQL
        UPDATE institutions SET
          student_veteran = TRUE, student_veteran_link = svas.student_veteran_link
        FROM svas
        WHERE institutions.cross = svas.cross AND svas.cross IS NOT NULL
        AND institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(str)
    end

    def self.add_owner(version_id)
      log_info_status 'Updating owner information'

      str = <<-SQL
        institutions.facility_code = institution_owners.facility_code
      SQL
      add_columns_for_update(version_id, InstitutionOwner, str)
    end

    def self.add_vsoc(version_id)
      str = <<-SQL
        institutions.facility_code = vsocs.facility_code
      SQL
      add_columns_for_update(version_id, Vsoc, str)
    end

    def self.add_eight_key(version_id)
      log_info_status 'Updating Eight Key information'

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
      log_info_status 'Updating Accredation type'

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
      log_info_status 'Updating Accredation status'
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
      log_info_status 'Building Caution Flag 1'
      caution_flag_clause = <<-SQL
        FROM accreditation_institute_campuses, accreditation_actions aa, institutions
        #{where_clause}
      SQL

      CautionFlag.build(version_id, AccreditationCautionFlag, caution_flag_clause)
    end

    def self.add_arf_gi_bill(version_id)
      log_info_status 'Updating Arf GI Bill information'
      str = <<-SQL
        UPDATE institutions SET gibill = arf_gi_bills.gibill
        FROM arf_gi_bills
        WHERE institutions.facility_code = arf_gi_bills.facility_code
        AND institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(str)
    end

    def self.add_post_911_stats(version_id)
      log_info_status 'Updating Post 911 Stats information'
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
      log_info_status 'Updating MOU information'
      str = <<-SQL
        UPDATE institutions SET
          dodmou = mous.dodmou,
          caution_flag = CASE WHEN mous.dod_status = TRUE THEN TRUE ELSE caution_flag END
        FROM mous
        WHERE institutions.ope = mous.ope
        AND institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(str)

      log_info_status 'Updating Caution Flag Reason'
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

      log_info_status 'Building Caution Flag 2'
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
      log_info_status 'Updating Sec 702 information'
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

      log_info_status 'Creating Caution Flag rows 3'
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
      log_info_status 'Updating Settlement information'
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
      log_info_status 'Updating IPED Caution Flag information'
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
      log_info_status 'Creating Caution Flag rows'
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
      log_info_status 'Creating IPEDs Caution Flag rows'
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
      log_info_status 'Updating HCM Caution Flag information'
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
      log_info_status 'Updating Outcome information'
      str = <<-SQL
        institutions.facility_code = outcomes.facility_code
      SQL
      add_columns_for_update(version_id, Outcome, str)
    end

    def self.add_stem_offered(version_id)
      log_info_status 'Updating Stem offered information'
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
      log_info_status 'Creating Yellow Ribbon Program rows'
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
      log_info_status 'Updating School Closure information'
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
      log_info_status 'Updating Vet Tec information'
      str = <<-SQL
      UPDATE institutions SET vet_tec_provider = TRUE
        from versions
        WHERE substring(institutions.facility_code, 2 , 1) = 'V'
        AND institutions.version_id = #{version_id}
      SQL
      Institution.connection.update(str)
    end

    def self.build_zip_code_rates_from_weams(version_id)
      log_info_status 'Creating Zip Code Rate information'
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
      log_info_status 'Updating Campus Type information'
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
      log_info_status 'Updating Sec103 information'
      str = <<-SQL
       -- set message based on sec103s
        UPDATE institutions SET #{columns_for_update(Sec103)},
          section_103_message = CASE
            WHEN sec103s.complies_with_sec_103 = true THEN
              'Yes'
            WHEN sec103s.complies_with_sec_103 = false THEN
              'No'
            ELSE institutions.section_103_message END,
          approved = CASE
            WHEN sec103s.complies_with_sec_103 = false THEN FALSE
            ELSE institutions.approved END
        FROM sec103s INNER JOIN weams ON weams.facility_code = sec103s.facility_code
        WHERE institutions.facility_code = sec103s.facility_code AND institutions.version_id = #{version_id};
      SQL

      Institution.connection.execute(InstitutionProgram.send(:sanitize_sql, [str]))
    end

    # edu_programs.length_in_weeks is being used twice because
    # it is a short term fix to an issue that they aren't sure how we should fix
    def self.build_institution_programs(version_id)
      log_info_status 'Creating Institution Program rows'
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
      log_info_status 'Creating Versioned School Certifying Officials rows'
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

    def self.add_provider_type(version_id)
      log_info_status 'Updating Provider Type information'
      str = <<-SQL
        UPDATE institutions SET
          school_provider = CASE WHEN institution_type_name IN (:schools) AND vet_tec_provider IS FALSE THEN TRUE ELSE FALSE END,
          employer_provider = CASE WHEN institution_type_name = :employer AND vet_tec_provider IS FALSE THEN TRUE ELSE FALSE END
        WHERE institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(Institution.sanitize_sql_for_conditions([str,
                                                                             { employer: Institution::EMPLOYER,
                                                                               schools: Institution::SCHOOLS }]))
    end

    def self.initial_buildout?
      production_version_id = Version.current_production.id if Version.current_production
      production_version_id.nil?
    end

    def self.geocode_using_csv_file
      PerformInsitutionTablesMaintenanceJob.perform_later unless production?
      sleep 120 # Give the vacuuming a chancd to more or less complete
      CSV.foreach('sample_csvs/institution_long_lat_ung.csv', headers: true, col_sep: ',') do |row|
        Institution.where(
          facility_code: row['facility_code']
        ).update(
          longitude: row['longitude'], latitude: row['latitude'], ungeocodable: row['ungeocodable']
        )
      end
    end

    # Pull forward into the current version the long/lat data for approved
    # institutions where the addy hasn't changed.
    def self.update_longitude_and_latitude(version_id)
      log_info_status 'Updating Longitude & Latitude information'
      # get current version id
      current_version_id = Version.current_production.id

      str = <<-SQL
        UPDATE institutions i SET
          latitude = prod_i.latitude,
          longitude = prod_i.longitude
        FROM (
          SELECT longitude, latitude, physical_address_1, physical_address_2, physical_address_3, physical_city, physical_state, physical_country, physical_zip, facility_code
          FROM institutions
          WHERE version_id = #{current_version_id}
          AND longitude IS NOT NULL
          AND latitude IS NOT NULL
          AND approved IS TRUE
          ) prod_i
        WHERE (i.latitude IS NULL AND i.longitude IS NULL)

        AND (i.physical_address_1 = prod_i.physical_address_1
            or (i.physical_address_1 is null and prod_i.physical_address_1 is null)
            )

        AND (i.physical_address_2 = prod_i.physical_address_2
            or (i.physical_address_2 is null and prod_i.physical_address_2 is null)
            )

        AND (i.physical_address_3 = prod_i.physical_address_3
            or (i.physical_address_3 is null and prod_i.physical_address_3 is null)
            )

        AND (i.physical_city = prod_i.physical_city
            or (i.physical_city is null and prod_i.physical_city is null)
            )

        AND (i.physical_state = prod_i.physical_state
            or (i.physical_state is null and prod_i.physical_state is null)
            )

        AND (i.physical_zip = prod_i.physical_zip
            or (i.physical_zip is null and prod_i.physical_zip is null)
            )

        AND i.physical_country = prod_i.physical_country
        AND i.facility_code = prod_i.facility_code
        AND i.version_id = #{version_id}
        AND i.approved IS TRUE
      SQL

      sql = Institution.send(:sanitize_sql, [str])
      Institution.connection.execute(sql)
    end

    # set the ungeocodable flag to true if it was ungeocodable and the addy has
    # not changed
    def self.update_ungeocodable(version_id)
      log_info_status 'Updating Ungeocodable flag'
      # get current version id
      current_version_id = Version.current_production.id

      str = <<-SQL
        UPDATE institutions i SET
          ungeocodable = true
        FROM (
          SELECT physical_address_1, physical_address_2, physical_address_3
               , physical_city, physical_state, physical_country, physical_zip
               , facility_code
            FROM institutions
           WHERE version_id = #{current_version_id}
             AND longitude    IS NULL
             AND latitude     IS NULL
             AND approved     IS TRUE
             AND ungeocodable IS TRUE
          ) prod_i
        WHERE (i.latitude IS NULL AND i.longitude IS NULL)

          AND (i.physical_address_1 = prod_i.physical_address_1
              or (i.physical_address_1 is null and prod_i.physical_address_1 is null))

          AND (i.physical_address_2 = prod_i.physical_address_2
              or (i.physical_address_2 is null and prod_i.physical_address_2 is null))

          AND (i.physical_address_3 = prod_i.physical_address_3
              or (i.physical_address_3 is null and prod_i.physical_address_3 is null))

          AND (i.physical_city = prod_i.physical_city
              or (i.physical_city is null and prod_i.physical_city is null))

          AND (i.physical_state = prod_i.physical_state
              or (i.physical_state is null and prod_i.physical_state is null))

          AND (i.physical_zip = prod_i.physical_zip
              or (i.physical_zip is null and prod_i.physical_zip is null))

          AND i.physical_country = prod_i.physical_country
          AND i.facility_code    = prod_i.facility_code
          AND i.version_id       = #{version_id}

          AND i.approved IS TRUE
      SQL

      sql = Institution.send(:sanitize_sql, [str])
      Institution.connection.execute(sql)
    end

    def self.geocode_institutions(version)
      start = Time.now.utc
      log_info_status 'Geocoding...'
      search_geocoder = SearchGeocoder.new(version)
      search_geocoder.process_geocoder_address if !Rails.env.eql?('test') && search_geocoder.by_address.present?
      version.update(geocoded: true)
      finish = Time.now.utc
      Rails.logger.info "\n\n\n"
      Rails.logger.info "*** Goecoding Beg: #{start}"
      Rails.logger.info "*** Geocoding End: #{finish}\n\n\n"
    end

    def self.delete_prior_preview_data(prior_preview_ids)
      prior_preview_ids.each do |pp_id|
        min_inst_id = Institution.where(version_id: pp_id).minimum(:id)
        unless min_inst_id # no insititutions for this preview
          Version.find(pp_id).destroy
          next
        end
        max_inst_id = Institution.where(version_id: pp_id).maximum(:id)
        delete_institution_data(pp_id, min_inst_id, max_inst_id)
        Version.find(pp_id).destroy
      end
    end

    def self.delete_institution_data(pp_id, min_inst_id, max_inst_id)
      [CautionFlag, VersionedSchoolCertifyingOfficial, InstitutionProgram,
       YellowRibbonProgram, InstitutionRating].each do |klass|
        log_info_status "deleting prior unpublished preview #{klass.name} data"
        klass
          .where('institution_id between ? and ?', min_inst_id, max_inst_id).in_batches.delete_all
      end

      log_info_status 'deleting prior preview Insititution data'
      Institution.where(version_id: pp_id).in_batches.delete_all
      log_info_status 'deleting prior preview ZipcodeRate data'
      ZipcodeRate.where(version_id: pp_id).in_batches.delete_all
    end

    def self.rate_institutions(version_id)
      log_info_status 'Creating Institution Rating rows'

      str = <<-SQL

      insert into institution_ratings(
        institution_id, q1_avg, q1_count, q2_avg, q2_count, q3_avg, q3_count, q4_avg, q4_count, q5_avg, q5_count, q7_avg, q7_count, q8_avg, q8_count,
        q9_avg, q9_count, q10_avg, q10_count, q11_avg, q11_count, q12_avg, q12_count, q13_avg, q13_count, q14_avg, q14_count, m1_avg,
        m2_avg, m3_avg, m4_avg, overall_avg, institution_rating_count
      )
        select institutions.id
              ,case when q1_weighted_count = 0 then 0 else round(q1_weighted_count/q1_count::numeric,1) end as q1_avg, q1_count
              ,case when q2_weighted_count = 0 then 0 else round(q2_weighted_count/q2_count::numeric,1) end as q2_avg, q2_count
              ,case when q3_weighted_count = 0 then 0 else round(q3_weighted_count/q3_count::numeric,1) end as q3_avg, q3_count
              ,case when q4_weighted_count = 0 then 0 else round(q4_weighted_count/q4_count::numeric,1) end as q4_avg, q4_count
              ,case when q5_weighted_count = 0 then 0 else round(q5_weighted_count/q5_count::numeric,1) end as q5_avg, q5_count
              ,case when q7_weighted_count = 0 then 0 else round(q7_weighted_count/q7_count::numeric,1) end as q7_avg, q7_count
              ,case when q8_weighted_count = 0 then 0 else round(q8_weighted_count/q8_count::numeric,1) end as q8_avg, q8_count
              ,case when q9_weighted_count = 0 then 0 else round(q9_weighted_count/q9_count::numeric,1) end as q9_avg, q9_count
              ,case when q10_weighted_count = 0 then 0 else round(q10_weighted_count/q10_count::numeric,1) end as q10_avg, q10_count
              ,case when q11_weighted_count = 0 then 0 else round(q11_weighted_count/q11_count::numeric,1) end as q11_avg, q11_count
              ,case when q12_weighted_count = 0 then 0 else round(q12_weighted_count/q12_count::numeric,1) end as q12_avg, q12_count
              ,case when q13_weighted_count = 0 then 0 else round(q13_weighted_count/q13_count::numeric,1) end as q13_avg, q13_count
              ,case when q14_weighted_count = 0 then 0 else round(q14_weighted_count/q14_count::numeric,1) end as q14_avg, q14_count
              ,case when q1_count = 0 and q2_count = 0 and q3_count = 0 and q4_count = 0 and q5_count = 0 then 0
               else
                 round(
                 (q1_weighted_count::numeric / m1_count) +
                 (q2_weighted_count::numeric / m1_count) +
                 (q3_weighted_count::numeric / m1_count) +
                 (q4_weighted_count::numeric / m1_count) +
                 (q5_weighted_count::numeric / m1_count)
                 ,1)
               end as m1_avg

               ,case when q7_count = 0 and q8_count = 0 and q9_count = 0 and q10_count = 0 then 0
               else
                 round(
                 (q7_weighted_count::numeric  / m2_count) +
                 (q8_weighted_count::numeric  / m2_count) +
                 (q9_weighted_count::numeric  / m2_count) +
                 (q10_weighted_count::numeric / m2_count)
                 ,1)
               end as m2_avg

               ,case when q11_count = 0 and q12_count = 0 then 0
               else
                round(
                 (q11_weighted_count::numeric / m3_count) +
                 (q12_weighted_count::numeric / m3_count)
                ,1)
               end as m3_avg

               ,case when q13_count = 0 and q14_count = 0 then 0
               else
                round(
                 (q13_weighted_count::numeric / m4_count) +
                 (q14_weighted_count::numeric / m4_count)
                ,1)
               end as m4_avg
               ,
              round(
               ((q1_weighted_count::numeric / overall_count)
               +(q2_weighted_count::numeric / overall_count)
               +(q3_weighted_count::numeric / overall_count)
               +(q4_weighted_count::numeric / overall_count)
               +(q5_weighted_count::numeric / overall_count)
               +(q7_weighted_count::numeric / overall_count)
               +(q8_weighted_count::numeric / overall_count)
               +(q9_weighted_count::numeric / overall_count)
               +(q10_weighted_count::numeric / overall_count)
               +(q11_weighted_count::numeric / overall_count)
               +(q12_weighted_count::numeric / overall_count)
               +(q13_weighted_count::numeric / overall_count)
               +(q14_weighted_count::numeric / overall_count))
              ,1) as overall_average
              ,institution_rating_count
         from (
                  select facility_code
                  ,sum(case when q1 is null or q1 <= 0 then 0 else 1 end) as q1_count
                  ,sum(case when q1 is null or q1 <= 0 then 0 when q1 > 4 then 4 else q1 end) as q1_weighted_count
                  ,sum(case when q2 is null or q2 <= 0 then 0 else 1 end) as q2_count
                  ,sum(case when q2 is null or q2 <= 0 then 0 when q2 > 4 then 4 else q2 end) as q2_weighted_count
                  ,sum(case when q3 is null or q3 <= 0 then 0 else 1 end) as q3_count
                  ,sum(case when q3 is null or q3 <= 0 then 0 when q3 > 4 then 4 else q3 end) as q3_weighted_count
                  ,sum(case when q4 is null or q4 <= 0 then 0 else 1 end) as q4_count
                  ,sum(case when q4 is null or q4 <= 0 then 0 when q4 > 4 then 4 else q4 end) as q4_weighted_count
                  ,sum(case when q5 is null or q5 <= 0 then 0 else 1 end) as q5_count
                  ,sum(case when q5 is null or q5 <= 0 then 0 when q5 > 4 then 4 else q5 end) as q5_weighted_count
                  ,sum(case when q7 is null or q7 <= 0 then 0 else 1 end) as q7_count
                  ,sum(case when q7 is null or q7 <= 0 then 0 when q7 > 4 then 4 else q7 end) as q7_weighted_count
                  ,sum(case when q8 is null or q8 <= 0 then 0 else 1 end) as q8_count
                  ,sum(case when q8 is null or q8 <= 0 then 0 when q8 > 4 then 4 else q8 end) as q8_weighted_count
                  ,sum(case when q9 is null or q9 <= 0 then 0 else 1 end) as q9_count
                  ,sum(case when q9 is null or q9 <= 0 then 0 when q9 > 4 then 4 else q9 end) as q9_weighted_count
                  ,sum(case when q10 is null or q10 <= 0 then 0 else 1 end) as q10_count
                  ,sum(case when q10 is null or q10 <= 0 then 0 when q10 > 4 then 4 else q10 end) as q10_weighted_count
                  ,sum(case when q11 is null or q11 <= 0 then 0 else 1 end) as q11_count
                  ,sum(case when q11 is null or q11 <= 0 then 0 when q11 > 4 then 4 else q11 end) as q11_weighted_count
                  ,sum(case when q12 is null or q12 <= 0 then 0 else 1 end) as q12_count
                  ,sum(case when q12 is null or q12 <= 0 then 0 when q12 > 4 then 4 else q12 end) as q12_weighted_count
                  ,sum(case when q13 is null or q13 <= 0 then 0 else 1 end) as q13_count
                  ,sum(case when q13 is null or q13 <= 0 then 0 when q13 > 4 then 4 else q13 end) as q13_weighted_count
                  ,sum(case when q14 is null or q14 <= 0 then 0 else 1 end) as q14_count
                  ,sum(case when q14 is null or q14 <= 0 then 0 when q14 > 4 then 4 else q14 end) as q14_weighted_count

                  ,sum(
                    (case when q1 is null or q1 <= 0 then 0 else 1 end) +
                    (case when q2 is null or q2 <= 0 then 0 else 1 end) +
                    (case when q3 is null or q3 <= 0 then 0 else 1 end) +
                    (case when q4 is null or q4 <= 0 then 0 else 1 end) +
                    (case when q5 is null or q5 <= 0 then 0 else 1 end)
             ) as m1_count
            ,sum(
              (case when q7 is null or q7 <= 0 then 0 else 1 end) +
              (case when q8 is null or q8 <= 0 then 0 else 1 end) +
              (case when q9 is null or q9 <= 0 then 0 else 1 end) +
              (case when q10 is null or q10 <= 0 then 0 else 1 end)
             ) as m2_count

            ,sum(
              (case when q11 is null or q11 <= 0 then 0 else 1 end) +
              (case when q12 is null or q12 <= 0 then 0 else 1 end)
             ) as m3_count

            ,sum(
              (case when q13 is null or q13 <= 0 then 0 else 1 end) +
              (case when q14 is null or q14 <= 0 then 0 else 1 end)
             ) as m4_count

            ,sum(
              (case when q1 is null or q1 <= 0 then 0 else 1 end) +
              (case when q2 is null or q2 <= 0 then 0 else 1 end) +
              (case when q3 is null or q3 <= 0 then 0 else 1 end) +
              (case when q4 is null or q4 <= 0 then 0 else 1 end) +
              (case when q5 is null or q5 <= 0 then 0 else 1 end) +
              (case when q7 is null or q7 <= 0 then 0 else 1 end) +
              (case when q8 is null or q8 <= 0 then 0 else 1 end) +
              (case when q9 is null or q9 <= 0 then 0 else 1 end) +
              (case when q10 is null or q10 <= 0 then 0 else 1 end) +
              (case when q11 is null or q11 <= 0 then 0 else 1 end) +
              (case when q12 is null or q12 <= 0 then 0 else 1 end) +
              (case when q13 is null or q13 <= 0 then 0 else 1 end) +
              (case when q14 is null or q14 <= 0 then 0 else 1 end)
             ) as overall_count

             ,count(*) as institution_rating_count
             from institution_school_ratings
             group by facility_code
             ) as facility_ratings inner join institutions on facility_ratings.facility_code = institutions.facility_code and institutions.version_id = #{version_id}
      SQL
      sql = InstitutionRating.send(:sanitize_sql, [str])
      InstitutionRating.connection.execute(sql)
    end

    def self.log_info_status(message)
      Rails.logger.info "*** #{Time.now.utc} #{message}"

      UpdatePreviewGenerationStatusJob.perform_later(message)
    end
  end
end

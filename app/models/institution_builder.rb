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
    columns = Crosswalk::USE_COLUMNS.map(&:to_s)

    str = 'UPDATE institutions SET '
    str += columns.map { |col| %("#{col}" = crosswalks.#{col}) }.join(', ')
    str += '  FROM crosswalks '
    str += '  WHERE institutions.facility_code = crosswalks.facility_code '
    str += "   AND institutions.version = #{version_number} "

    Institution.connection.update(str)
  end

  def self.add_sva(version_number)
    str = 'UPDATE institutions SET '
    str += '  student_veteran = TRUE, student_veteran_link = svas.student_veteran_link'
    str += '  FROM svas '
    str += '  WHERE institutions.cross = svas.cross AND svas.cross IS NOT NULL'
    str += "    AND institutions.version = #{version_number} "

    Institution.connection.update(str)
  end

  def self.add_vsoc(version_number)
    columns = Vsoc::USE_COLUMNS.map(&:to_s)

    str = 'UPDATE institutions SET '
    str += columns.map { |col| %("#{col}" = vsocs.#{col}) }.join(', ')
    str += '  FROM vsocs '
    str += '  WHERE institutions.facility_code = vsocs.facility_code'
    str += "    AND institutions.version = #{version_number}; "

    Institution.connection.update(str)
  end

  def self.add_eight_key(version_number)
    str = 'UPDATE institutions SET eight_keys = TRUE '
    str += ' FROM eight_keys '
    str += ' WHERE institutions.cross = eight_keys.cross'
    str += '   AND eight_keys.cross IS NOT NULL'
    str += "    AND institutions.version = #{version_number}; "

    Institution.connection.update(str)
  end

  # Updates the institution table with data from the accreditations table. There is an explict
  # ordering of both accreditation type and status for those schools having conflicting types
  # hybrid < national < regional, and for status: 'show cause' < probation. There is a
  # requirement to include only those accreditations that are institutional and currently active.
  def self.add_accreditation(version_number)
    # Set the accreditation_type according to the hierarchy hybrid < national < regional
    str = ' UPDATE institutions SET accreditation_type = CASE '
    str += "  WHEN at_types @> '{ regional }' THEN 'regional' "
    str += "  WHEN at_types @> '{ national }' THEN 'national' "
    str += "  WHEN at_types @> '{ hybrid }' THEN 'hybrid' "
    str += '  ELSE NULL '
    str += 'END '
    str += 'FROM ('
    str += 'SELECT "cross", array_agg(DISTINCT(accreditation_type)) AS at_types '
    str += 'FROM accreditations '
    str += 'WHERE "cross" IS NOT NULL '
    str += '  AND accreditation_type IS NOT NULL '
    str += "  AND periods LIKE '%current%' "
    str += "  AND csv_accreditation_type = 'institutional' "
    str += 'GROUP BY "cross") AS cross_type_arr '
    str += 'WHERE cross_type_arr.cross = institutions.cross '
    str += "  AND institutions.version = #{version_number} "

    Institution.connection.update(str)

    # Set the accreditation_status according to the hierarchy probation < show cause
    str = ' UPDATE institutions SET accreditation_status = CASE '
    str += "  WHEN as_statuses @> '{ regional }' THEN 'regional' "
    str += "  WHEN as_statuses @> '{ show cause }' THEN 'show cause' "
    str += "  WHEN as_statuses @> '{ probation }' THEN 'probation' "
    str += '  ELSE NULL '
    str += 'END '
    str += 'FROM ('
    str += '  SELECT "cross", accreditation_type, array_agg(DISTINCT(accreditation_status)) AS as_statuses '
    str += '    FROM accreditations '
    str += '    WHERE "cross" IS NOT NULL '
    str += '      AND accreditation_type IS NOT NULL '
    str += "      AND (accreditation_status = 'probation' OR accreditation_status = 'show cause') "
    str += "      AND periods LIKE '%current%' "
    str += "      AND csv_accreditation_type = 'institutional' "
    str += '    GROUP BY "cross", accreditation_type) AS cross_status_arr '
    str += 'WHERE institutions.cross = cross_status_arr.cross '
    str += '  AND institutions.accreditation_type = cross_status_arr.accreditation_type '
    str += "  AND institutions.version = #{version_number} "

    Institution.connection.update(str)

    # Sets the caution flag for all accreditations that have a non-null status. Note,
    # that institutional type accreditations are always, null, probation, or show cause.
    str = ' UPDATE institutions SET '
    str += '  caution_flag = TRUE '
    str += 'FROM accreditations '
    str += 'WHERE institutions.cross = accreditations.cross '
    str += '  AND accreditations.cross IS NOT NULL '
    str += "  AND accreditations.periods LIKE '%current%' "
    str += '  AND accreditations.accreditation_status IS NOT NULL '
    str += "  AND accreditations.csv_accreditation_type = 'institutional'; "

    Institution.connection.update(str)

    # Sets the caution flag reason for all accreditations that have a non-null status.
    # The innermost subquery retrieves a distinct set of statuses (it is plausible that
    # identical statuses may apply to the same school but from different agencies).
    str = ' UPDATE institutions SET '
    str += "  caution_flag_reason = concat_ws(', ', caution_flag_reason, reasons_list.reasons) "
    str += 'FROM ('
    str += '  SELECT "cross", '
    str += "    array_to_string(array_agg(distinct('Accreditation ('||accreditation_status||')')), ', ') AS reasons "
    str += '  FROM accreditations '
    str += '  WHERE "cross" IS NOT NULL '
    str += '   AND accreditation_status IS NOT NULL '
    str += "   AND periods LIKE '%current%' "
    str += "  AND csv_accreditation_type = 'institutional' "
    str += '  GROUP BY "cross" ) reasons_list '
    str += 'WHERE institutions.cross = reasons_list.cross '

    Institution.connection.update(str)
  end

  def self.add_arf_gi_bill
    str = 'UPDATE institutions SET '
    str += ' gibill = arf_gi_bills.gibill '
    str += ' FROM arf_gi_bills '
    str += 'WHERE institutions.facility_code = arf_gi_bills.facility_code'

    Institution.connection.update(str)
  end

  def self.add_p911_tf
    columns = P911Tf::USE_COLUMNS.map(&:to_s)

    str = 'UPDATE institutions SET '
    str += columns.map { |col| %("#{col}" = p911_tfs.#{col}) }.join(', ')
    str += ' FROM p911_tfs '
    str += 'WHERE institutions.facility_code = p911_tfs.facility_code'

    Institution.connection.update(str)
  end

  def self.add_p911_yr
    columns = P911Yr::USE_COLUMNS.map(&:to_s)

    str = 'UPDATE institutions SET '
    str += columns.map { |col| %("#{col}" = p911_yrs.#{col}) }.join(', ')
    str += ' FROM p911_yrs '
    str += 'WHERE institutions.facility_code = p911_yrs.facility_code'

    Institution.connection.update(str)
  end

  def self.add_mou
    reason = 'DoD Probation For Military Tuition Assistance'

    # Sets the caution flag for any approved school having a probatiton or
    # title IV non-compliance (status == true)
    str = 'UPDATE institutions SET '
    str += ' dodmou = mous.dodmou, caution_flag = CASE '
    str += '   WHEN mous.dod_status = TRUE THEN TRUE ELSE caution_flag '
    str += ' END '
    str += ' FROM mous '
    str += 'WHERE institutions.ope6 = mous.ope6; '

    Institution.connection.update(str)

    # Sets dodmou for any approved school having a probatiton or
    # title IV non-compliance status. The caution flag reason is only
    # affected by a DoD probation status
    str = ' UPDATE institutions SET '
    str += "  caution_flag_reason = concat_ws(', ', caution_flag_reason, reasons_list.reason) "
    str += 'FROM ( '
    str += "  SELECT distinct(ope6), '#{reason}' AS reason FROM mous WHERE dod_status = TRUE "
    str += ') as reasons_list '
    str += 'WHERE institutions.ope6 = reasons_list.ope6; '

    Institution.connection.update(str)
  end

  def self.add_scorecard
    columns = Scorecard::USE_COLUMNS.map(&:to_s)

    str = 'UPDATE institutions SET '
    str += columns.map { |col| %("#{col}" = scorecards.#{col}) }.join(', ')
    str += ' FROM scorecards '
    str += 'WHERE institutions.cross = scorecards.cross'

    Institution.connection.update(str)
  end

  def self.add_ipeds_ic
    columns = IpedsIc::USE_COLUMNS.map(&:to_s)

    str = 'UPDATE institutions SET '
    str += columns.map { |col| %("#{col}" = ipeds_ics.#{col}) }.join(', ')
    str += ' FROM ipeds_ics '
    str += 'WHERE institutions.cross = ipeds_ics.cross'

    Institution.connection.update(str)
  end

  def self.add_ipeds_hd
    str = 'UPDATE institutions SET '
    str += 'vet_tuition_policy_url = ipeds_hds.vet_tuition_policy_url'
    str += ' FROM ipeds_hds '
    str += 'WHERE institutions.cross = ipeds_hds.cross'

    Institution.connection.update(str)
  end

  def self.add_ipeds_ic_ay
    columns = IpedsIcAy::USE_COLUMNS.map(&:to_s)

    str = 'UPDATE institutions SET '
    str += columns.map { |col| %("#{col}" = ipeds_ic_ays.#{col}) }.join(', ')
    str += ' FROM ipeds_ic_ays '
    str += 'WHERE institutions.cross = ipeds_ic_ays.cross'

    Institution.connection.update(str)
  end

  def self.add_ipeds_ic_py
    columns = IpedsIcPy::USE_COLUMNS.map(&:to_s)

    str = 'UPDATE institutions SET '

    str += columns.map do |col|
      %("#{col}" = CASE WHEN institutions.#{col} IS NULL THEN ipeds_ic_pies.#{col} ELSE institutions.#{col} END)
    end.join(', ')

    str += ' FROM ipeds_ic_pies '
    str += 'WHERE institutions.cross = ipeds_ic_pies.cross'

    Institution.connection.update(str)
  end

  def self.add_sec_702
    # When overlapping, sec_702 data from sec702_schools has precedence over data from sec702_schools, and
    # only approved public schools can be SEC 702 complaint
    reason = 'Does Not Offer Required In-State Tuition Rates'

    str = ' UPDATE institutions SET '
    str += '  sec_702 = s702_list.sec_702, caution_flag = NOT s702_list.sec_702, '
    str += '  caution_flag_reason = CASE WHEN NOT s702_list.sec_702 '
    str += "    THEN concat_ws(',', caution_flag_reason, '#{reason}') ELSE caution_flag_reason END "
    str += '  FROM ( '
    str += '    SELECT facility_code, sec702s.sec_702 FROM institutions '
    str += '      INNER JOIN sec702s ON sec702s.state = institutions.state '
    str += '      EXCEPT SELECT facility_code, sec_702 FROM sec702_schools '
    str += '    UNION SELECT facility_code, sec_702 FROM sec702_schools '
    str += '  ) AS s702_list '
    str += '  WHERE institutions.facility_code = s702_list.facility_code '
    str += "    AND institutions.institution_type_name = 'public'"

    Institution.connection.update(str)
  end
end

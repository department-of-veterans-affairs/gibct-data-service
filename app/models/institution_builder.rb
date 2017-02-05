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

  def self.valid_user?(user)
    User.find_by(email: user.email).present?
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

  def self.run_insertions(version)
    initialize_with_weams(version)
    add_crosswalk
    add_sva
    add_vsoc
    add_eight_key
  end

  def self.run(user)
    raise(ArgumentError, "'#{user.try(:email)}' is not a valid user") unless valid_user?(user)
    return nil unless buildable?

    version = Version.create(production: false, user: user)

    default_timestamps_to_now
    run_insertions(version.version)
    drop_default_timestamps

    version
  end

  def self.initialize_with_weams(version)
    columns = Weam::USE_COLUMNS.map(&:to_s)

    institutions = Weam.select(columns).where(approved: true).map(&:attributes).each_with_object([]) do |weam, a|
      a << Institution.new(weam.except('id').merge(version: version))
    end

    # No validations here, Weam was validated on import - don't need to waste time with unique checks
    Institution.import institutions, validate: false, ignore: true
  end

  def self.add_crosswalk
    columns = Crosswalk::USE_COLUMNS.map(&:to_s)

    str = 'UPDATE institutions SET '
    str += columns.map { |col| %("#{col}" = crosswalks.#{col}) }.join(', ')
    str += ' FROM crosswalks WHERE institutions.facility_code = crosswalks.facility_code'

    Institution.connection.update(str)
  end

  def self.add_sva
    columns = Sva::USE_COLUMNS.map(&:to_s)

    str = 'UPDATE institutions SET '
    str += 'student_veteran = TRUE, '
    str += columns.map { |col| %("#{col}" = svas.#{col}) }.join(', ')
    str += ' FROM svas WHERE institutions.cross = svas.cross AND svas.cross IS NOT NULL'

    Institution.connection.update(str)
  end

  def self.add_vsoc
    columns = Vsoc::USE_COLUMNS.map(&:to_s)

    str = 'UPDATE institutions SET '
    str += columns.map { |col| %("#{col}" = vsocs.#{col}) }.join(', ')
    str += ' FROM vsocs WHERE institutions.facility_code = vsocs.facility_code'

    Institution.connection.update(str)
  end

  def self.add_eight_key
    str = 'UPDATE institutions SET eight_keys = TRUE '
    str += ' FROM eight_keys WHERE institutions.cross = eight_keys.cross'
    str += ' AND eight_keys.cross IS NOT NULL'

    Institution.connection.update(str)
  end

  # Updates the institution table with data from the accreditations table. There is an explict
  # ordering of both accreditation type and status for those schools having conflicting types
  # hybrid < national < regional, and for status: 'show cause' < probation. There is a
  # requirement to include only those accreditations that are institutional and currently active.
  def self.update_with_accreditation
    # Sets all accreditations that are hybrid types first
    str = 'UPDATE institutions SET '
    str += 'accreditation_type = accreditations.accreditation_type'
    str += ' FROM accreditations '
    str += 'WHERE institutions.cross = accreditations.cross '
    str += 'AND accreditations.cross IS NOT NULL '
    str += %(AND LOWER(accreditations.periods) LIKE '%current%' )
    str += %(AND LOWER(accreditations.csv_accreditation_type) = 'institutional' )
    str += "AND LOWER(accreditations.accreditation_type) = 'hybrid'; "

    # Sets all accreditations that are national, overriding conflicts with hybrids
    str += 'UPDATE institutions SET '
    str += 'accreditation_type = accreditations.accreditation_type'
    str += ' FROM accreditations '
    str += 'WHERE institutions.cross = accreditations.cross '
    str += 'AND accreditations.cross IS NOT NULL '
    str += %(AND LOWER(accreditations.periods) LIKE '%current%' )
    str += %(AND LOWER(accreditations.csv_accreditation_type) = 'institutional' )
    str += "AND LOWER(accreditations.accreditation_type) = 'national';"

    # Sets all accreditations that are regional, overriding conflicts with hybrids and nationals
    str += 'UPDATE institutions SET '
    str += 'accreditation_type = accreditations.accreditation_type'
    str += ' FROM accreditations '
    str += 'WHERE institutions.cross = accreditations.cross '
    str += 'AND accreditations.cross IS NOT NULL '
    str += %(AND LOWER(accreditations.periods) LIKE '%current%' )
    str += %(AND LOWER(accreditations.csv_accreditation_type) = 'institutional' )
    str += "AND LOWER(accreditations.accreditation_type) = 'regional'; "

    # Sets status for probationary accreditations, the status being derived from the
    # higest level of accreditation (hybrid, national, regional).
    str += 'UPDATE institutions SET '
    str += 'accreditation_status = accreditations.accreditation_status'
    str += ' FROM accreditations '
    str += 'WHERE institutions.cross = accreditations.cross '
    str += 'AND institutions.accreditation_type = accreditations.accreditation_type '
    str += 'AND accreditations.cross IS NOT NULL '
    str += %(AND LOWER(accreditations.periods) LIKE '%current%' )
    str += "AND LOWER(accreditations.csv_accreditation_type) = 'institutional' "
    str += "AND LOWER(accreditations.accreditation_status) = 'probation'; "

    # Sets status for show cause accreditations, overwriting probationary statuses,
    # the status being derived from the higest level of accreditation (hybrid, national, regional).
    str += 'UPDATE institutions SET '
    str += 'accreditation_status = accreditations.accreditation_status'
    str += ' FROM accreditations '
    str += 'WHERE institutions.cross = accreditations.cross '
    str += 'AND institutions.accreditation_type = accreditations.accreditation_type '
    str += 'AND accreditations.cross IS NOT NULL '
    str += %(AND LOWER(accreditations.periods) LIKE '%current%' )
    str += "AND LOWER(accreditations.csv_accreditation_type) = 'institutional' "
    str += "AND LOWER(accreditations.accreditation_status) = 'show cause'; "

    # Sets the caution flag for all accreditations that have a non-null status. Note,
    # that institutional type accreditations are always, null, probation, or show cause.
    str += 'UPDATE institutions SET '
    str += 'caution_flag = TRUE'
    str += ' FROM accreditations '
    str += 'WHERE institutions.cross = accreditations.cross '
    str += 'AND accreditations.cross IS NOT NULL '
    str += %(AND LOWER(accreditations.periods) LIKE '%current%' )
    str += 'AND accreditations.accreditation_status IS NOT NULL '
    str += "AND LOWER(accreditations.csv_accreditation_type) = 'institutional'; "

    # Sets the caution flag reason for all accreditations that have a non-null status.
    # The innermost subquery retrieves a unique set of statues (it is plausible that
    # identical statuses may apply to the same school but from different agencies). We
    # don't want to repeat the same reasons. The outer subquery then concatentates these
    # unique reasons into a comma-separated string. Lastly the outer UPDATE-CASE appends
    # these caution flag reasons to any existing caution flag reasons.
    str += 'UPDATE institutions SET caution_flag_reason = '
    str += 'CASE WHEN institutions.caution_flag_reason IS NULL THEN '
    str += '  AGG.ad '
    str += 'ELSE '
    str += "  CONCAT(institutions.caution_flag_reason, ', ', AGG.ad) "
    str += 'END '
    str += 'FROM ( '
    str += "  SELECT A.cross, string_agg(A.AST, ', ') AS ad "
    str += '    FROM ('
    str += "      SELECT a.cross, 'Accreditation (' || a.accreditation_status || ')' as AST"
    str += '      FROM accreditations a '
    str += '      WHERE '
    str += '        a.cross IS NOT NULL AND '
    str += '        a.accreditation_status IS NOT NULL AND '
    str += "        LOWER(a.periods) LIKE '%current%' AND "
    str += "        LOWER(a.csv_accreditation_type) = 'institutional' "
    str += '      GROUP BY a.cross, a.accreditation_status '
    str += '    ) A '
    str += '  GROUP BY A.cross '
    str += ') AGG '
    str += 'WHERE institutions.cross = AGG.cross; '

    Institution.connection.update(str)
  end
end

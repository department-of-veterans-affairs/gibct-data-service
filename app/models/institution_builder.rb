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
end

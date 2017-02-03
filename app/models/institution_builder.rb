# frozen_string_literal: true
module InstitutionBuilder
  TABLES = [
    Accreditation, ArfGiBill, Complaint, Crosswalk, EightKey, Hcm, IpedsHd,
    IpedsIcAy, IpedsIcPy, IpedsIc, Mou, Outcome, P911Tf, P911Yr, Scorecard,
    Sec702School, Sec702, Settlement, Sva, Vsoc, Weam
  ].freeze

  def self.buildable?
    TABLES.map(&:count).reject { |c| c > 0 }.blank?
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
  end

  def self.run(user)
    raise(ArgumentError, "'#{user.try(:email)}' is not a valid user") unless valid_user?(user)
    return nil unless buildable?

    version = Version.create(production: false, user: user)

    default_timestamps_to_now
    run_insertions(version)
    drop_default_timestamps

    version
  end

  def self.initialize_with_weams(version)
    names = Weam::USE_COLUMNS.map(&:to_s).join(', ')

    # Include only those schools marked as approved (c.f., Weam model)
    query = "INSERT INTO institutions (#{names}, version) ("
    query += Weam.select(names).select("#{version.version} as version").where(approved: true).to_sql + ')'

    ActiveRecord::Base.connection.execute(query)
  end
end

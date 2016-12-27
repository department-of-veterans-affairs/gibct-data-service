# frozen_string_literal: true
class Version < ActiveRecord::Base
  TIME_TYPES = [DateTime, Time, ActiveSupport::TimeWithZone].freeze

  belongs_to :user, inverse_of: :versions

  validates :version, presence: true, numericality: { only_integer: true }

  validates_associated :user
  validates :user_id, presence: true

  scope :production, -> { where(production: true) }
  scope :preview, -> { where(production: false) }

  def self.preview_version=(version = nil)
    # create a new preview version record
  end

  def self.production_version=(version = nil)
    # If version is nil, take the last preview version and increment max version number to create a new ver
    # if not nil, it must exist
    # create a new product version record
  end

  def self.production_version
    find_max_version
  end

  def self.preview_version
    find_max_version false
  end

  def self.production_version_by_time(time)
    find_version_by_time(time)
  end

  def self.preview_version_by_time(time)
    find_version_by_time(time, false)
  end

  def self.find_version_by_time(time, production = true)
    time = Time.zone.parse(time).to_datetime if time.is_a?(String)

    query = 'SELECT * FROM versions '\
            'INNER JOIN '\
              '(SELECT max(created_at) AS max_created_at FROM versions WHERE production=? AND created_at<?) as mv '\
              'ON created_at=mv.max_created_at '\
            'WHERE production=?;'

    Version.find_by_sql([query, production, time, production]).first
  end

  def self.find_max_version(production = true)
    query = 'SELECT * FROM versions '\
            'INNER JOIN '\
              '(SELECT max(created_at) AS max_created_at FROM versions WHERE production=?) as mv '\
              'ON created_at=mv.max_created_at '\
            'WHERE production=?;'

    Version.find_by_sql([query, production, production]).first
  end
end

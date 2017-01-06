# frozen_string_literal: true
class Version < ActiveRecord::Base
  belongs_to :user, inverse_of: :versions

  validates :version, presence: true, numericality: { only_integer: true }

  validates_associated :user
  validates :user_id, presence: true

  scope :production, -> { where(production: true) }
  scope :preview, -> { where(production: false) }

  scope :max_by_time, -> { order(:created_at).last }

  def self.preview_version=(version = nil)
    raise "Version #{version} does not exist" if version.present?
  end

  def self.production_version=(_version = nil)
    # If version is nil, take the last preview version and increment max version number to create a new ver
    # if not nil, it must exist
    # create a new product version record
  end

  def self.production_version
    Version.production.max_by_time
  end

  def self.preview_version
    Version.preview.max_by_time
  end

  def self.production_version_by_time(time)
    time = Time.zone.parse(time).to_datetime if time.is_a?(String)
    Version.production.where('created_at <= ?', time).max_by_time
  end

  def self.preview_version_by_time(time)
    time = Time.zone.parse(time).to_datetime if time.is_a?(String)
    Version.preview.where('created_at <= ?', time).max_by_time
  end
end

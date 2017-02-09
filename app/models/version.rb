# frozen_string_literal: true
class Version < ActiveRecord::Base
  belongs_to :user, inverse_of: :versions
  alias_attribute :created_by, :user

  validates_associated :user
  validates :user_id, presence: true

  before_validation :check_version
  before_save :increment_version

  def check_version
    if number.present? && Version.find_by(number: number).nil?
      errors.add(:number, "Version number #{number} doesn't exist")
    end
    true
  end

  def increment_version
    self.number = (Version.maximum(:number) || 0) + 1 if number.nil?
  end

  scope :production, -> { where(production: true) }
  scope :preview, -> { where(production: false) }

  scope :newest, -> { order(created_at: :desc).first }
  scope :as_of, lambda { |time|
    time = Time.zone.parse(time).to_datetime if time.is_a?(String)
    where('created_at <= ?', time).newest
  }

  def self.production_version
    Version.production.newest
  end

  def self.preview_version
    Version.preview.newest
  end

  def self.default_version_number
    Version.production.newest.number
  rescue
    nil
  end

  def self.production_version_by_time(time)
    Version.production.as_of(time)
  end

  def self.preview_version_by_time(time)
    Version.preview.as_of(time)
  end
end

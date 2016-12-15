# frozen_string_literal: true
class Version < ActiveRecord::Base
  TIME_TYPES = [DateTime, Time, ActiveSupport::TimeWithZone].freeze

  validates :number, presence: true, numericality: { only_integer: true }
  validates :by, presence: true, unless: proc { |v| v.approved_on_before_type_cast.nil? }
  validate :validate_approved_on

  scope :production, -> { where.not(approved_on: nil) }
  scope :preview, -> { where(approved_on: nil) }

  def self.production_version
    Version.production.maximum(:number)
  end

  def self.preview_version
    Version.preview.maximum(:number)
  end

  def self.production_version_at(time)
    time = Time.zone.parse(time).to_datetime if time.is_a?(String)
    Version.production.where('approved_on <= ?', time).maximum(:number)
  end

  def self.preview_version_at(time)
    time = Time.zone.parse(time).to_datetime if time.is_a?(String)
    Version.preview.where('created_at <= ?', time).maximum(:number)
  end

  protected

  def validate_approved_on
    return if approved_on_before_type_cast.nil? || TIME_TYPES.include?(approved_on_before_type_cast.class)
    begin
      DateTime.parse(approved_on_before_type_cast).in_time_zone.to_datetime
    rescue ArgumentError
      errors.add(:approved_on, "'#{approved_on_before_type_cast}' is not a valid DateTime")
    end
  end
end

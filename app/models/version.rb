# frozen_string_literal: true

require 'securerandom'

class Version < ApplicationRecord
  belongs_to :user, inverse_of: :versions
  alias_attribute :created_by, :user

  validates_associated :user
  validates :user_id, presence: true

  before_validation :check_version
  before_create :generate_uuid
  before_save :increment_version

  # scopes should always return active record relation
  scope :production, -> { where(production: true) }
  scope :preview, -> { where(production: false) }
  scope :newest, -> { order(created_at: :desc) }

  # class methods
  def self.current_production
    Version.production.newest.first
  end

  def self.previous_production
    Version.production.newest.second
  end

  def self.current_preview
    if Version.current_production && Version.preview.newest.first.created_at < Version.current_production.created_at
      return Version.current_production
    end

    Version.preview.newest.first
  end

  def self.previews_exist?
    Version.newest.first.preview?
  end

  # public instance methods
  def preview?
    !production?
  end

  def generating?
    preview? && completed_at.nil?
  end

  def publishable?
    !generating? && number > Version.production.maximum(:number)
  end

  def current_preview?
    preview? && number == Version.preview.maximum(:number)
  end
  alias latest_preview? current_preview?

  def current_production?
    production? && number == Version.production.maximum(:number)
  end
  alias latest_production? current_production?

  def gibct_link
    version_info = production? ? '' : "?version=#{uuid}"
    "#{ENV['GIBCT_URL']}#{version_info}"
  end

  # private instance methods
  private

  def check_version
    if number.present? && Version.find_by(number: number).nil?
      errors.add(:number, "Version number #{number} doesn't exist")
    end
    true
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def increment_version
    self.number = (Version.maximum(:number) || 0) + 1 if number.nil?
  end
end

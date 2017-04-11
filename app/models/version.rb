# frozen_string_literal: true
require 'securerandom'

class Version < ActiveRecord::Base
  belongs_to :user, inverse_of: :versions
  alias_attribute :created_by, :user

  validates_associated :user
  validates :user_id, presence: true

  before_validation :check_version
  before_create :generate_uuid
  before_save :increment_version

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

  scope :production, -> { where(production: true) }
  scope :preview, -> { where(production: false) }

  scope :newest, -> { order(created_at: :desc).first }
  scope :as_of, lambda { |time|
    time = Time.zone.parse(time).to_datetime if time.is_a?(String)
    where('created_at <= ?', time).newest
  }

  def preview?
    number != Version.production_version.number
  rescue
    true
  end

  # TODO: BEFORE PRODUCTION RELEASE, consider adding the GIBCT_HOST link and removing additional logic
  def gibct_link
    version_info = production? ? '' : "?version=#{uuid}"
    return "#{ENV['GIBCT_HOST']}#{version_info}" if ENV['GIBCT_HOST']

    base_link = ENV['LINK_HOST'].gsub(%r{(^\w+:|^)\/\/}, '').split('.')
    base_link = if base_link.size == 3 # dev, staging, or production
                  "https://#{base_link[0].gsub(/(-api|api)/, '')}.vets.gov"
                else # localhost (where 3000 gids, 3001 vets-api, and 3002 vets-website)
                  'http://localhost:3002'
                end
    "#{base_link}/gi-bill-comparison-tool#{version_info}"
  end

  def self.production_version
    Version.production.newest
  end

  def self.preview_version
    Version.preview.newest
  end

  def self.default_version
    Version.production.newest
  end

  def self.production_version_by_time(time)
    Version.production.as_of(time)
  end

  def self.preview_version_by_time(time)
    Version.preview.as_of(time)
  end
end

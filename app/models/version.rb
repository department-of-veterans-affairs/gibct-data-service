# frozen_string_literal: true

require 'securerandom'

class Version < ApplicationRecord
  has_many :institutions, dependent: :nullify
  has_many :zipcode_rates, dependent: :nullify
  has_many :calculator_constant_versions, dependent: :nullify
  has_many :calculator_constant_versions_archives, dependent: :nullify
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

  # We want to keep this method because the version is not status 'production' until
  # all steps are successfully completed.
  def self.current_preview
    cp = preview.newest
    cp = cp.where('created_at > ?', current_production.created_at) if current_production
    cp.first
  end

  def self.latest
    Version.newest.first
  end

  def self.archived
    Version.select('distinct on (number) *')
           .where('number < ? and production = true', Version.current_production&.number)
           .order(number: :desc)
  end

  # Used by Calculator Constants to find most recently versioned records as of a specific year
  def self.latest_from_year(year)
    raise ArgumentError, 'Must provide a valid year' unless year.is_a?(Integer)

    Version.where('extract(year from completed_at) = ?', year)
           .order(number: :desc)
           .first
  end

  # Inclusive of start and end year
  # Used by Calculator Constants to produce export of records over range of years
  def self.latest_from_year_range(start_year, end_year)
    raise ArgumentError, 'Must provide a valid year' unless [start_year, end_year].all? { |y| y.is_a?(Integer) }
    raise ArgumentError, 'Start year must be less than or equal to end year' if start_year > end_year

    (start_year..end_year).map { |y| latest_from_year(y) }.compact
  end

  # public instance methods
  def preview?
    !production?
  end

  def generating?
    preview? && completed_at.nil?
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

  def sandbox_link
    version_info = production? ? '' : "?version=#{uuid}"
    "#{ENV['SANDBOX_URL']}#{version_info}"
  end

  def as_json(_options = nil)
    {
      number: number,
      created_at: created_at,
      preview: preview?
    }
  end

  # private instance methods
  private

  def check_version
    errors.add(:number, "Version number #{number} doesn't exist") if number.present? && Version.find_by(number: number).nil?
    true
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def increment_version
    self.number = (Version.maximum(:number) || 0) + 1 if number.nil?
  end
end

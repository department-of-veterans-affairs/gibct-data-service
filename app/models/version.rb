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
    Version.preview.newest.first
  end

  def self.previews_exist?
    Version.newest.first.preview?
  end

  def self.buildable?
    Version.buildable_state.to_s.match('can_create')
  end

  def self.buildable_state
    upload_dates = Upload.last_uploads
    .to_a
    .select{ |upload| CsvTypes.required_table_names.include?(upload.csv_type)}
    .map(&:updated_at)

    preview = Version.current_preview
    return :not_enough_uploads if upload_dates.length < CsvTypes.required_table_names.length
    return :too_many_uploads if upload_dates.length > CsvTypes.required_table_names.length
    return :can_create_first_preview if preview.nil?
    return :can_create_new_preview if upload_dates.max > preview.created_at
    :no_new_uploads
  end

  def self.buildable_state_msg
    Version.buildable_state.to_s.split('_').map(&:capitalize).join(' ')
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

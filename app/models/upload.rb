# frozen_string_literal: true

class Upload < ApplicationRecord
  attr_accessor :skip_lines, :upload_file, :upload_files

  belongs_to :user, inverse_of: :versions

  validates_associated :user
  validates :user_id, presence: true

  validates :csv, presence: true

  validate :csv_type_check?

  after_initialize :derive_dependent_columns, unless: :persisted?

  DEAD_AFTER = Settings.async_upload.dead_after.seconds

  def derive_dependent_columns
    self.csv ||= upload_file.try(:original_filename)
  end

  def ok?
    ok
  end

  def active?
    pending? && canceled_at.blank? && Time.now.utc < dead_at
  end

  def inactive?
    !active?
  end

  def pending?
    return false unless async_enabled?

    completed_at.blank? && queued_at
  end

  def clean!
    update(blob: nil, status_message: nil)
  end

  def cancel!
    raise StandardError, "Upload cannot be canceled" unless active?
    
    clean! && update(canceled_at: Time.now.utc.to_fs(:db))
  end

  def csv_type_check?
    return true if [*UPLOAD_TYPES_ALL_NAMES, Institution.name].include?(csv_type)

    if csv_type.present?
      errors.add(:csv_type, "#{csv_type} is not a valid CSV data source")
    else
      errors.add(:csv_type, 'cannot be blank.')
    end

    false
  end

  def liberal_parsing
    Common::Shared.file_type_defaults(csv_type)[:liberal_parsing]
  end

  def clean_rows
    Common::Shared.file_type_defaults(csv_type)[:clean_rows]
  end

  def multiple_files
    Common::Shared.file_type_defaults(csv_type)[:multiple_files]
  end

  def async_upload_settings
    Common::Shared.file_type_defaults(csv_type)[:async_upload].transform_keys(&:to_sym)
  end

  def async_enabled?
    async_upload_settings[:enabled]
  end

  def chunk_size
    async_upload_settings[:chunk_size]
  end

  def create_or_concat_blob
    File.open(upload_file.tempfile.path, 'rb') do |file|
      new_blob = upload_file.tempfile.read
      updated_blob = blob ? blob.concat(new_blob) : new_blob
      update(blob: updated_blob)
    end
  ensure
    upload_file.tempfile.close
    upload_file.tempfile.unlink
  end

  def self.last_uploads(for_display = false)
    csv_types = if for_display
                  UPLOAD_TYPES_ALL_NAMES
                else
                  [*UPLOAD_TYPES_ALL_NAMES]
                end

    Upload.select('DISTINCT ON("csv_type") *')
          .where(ok: true, csv_type: csv_types)
          .order(csv_type: :asc, updated_at: :desc)
  end

  def self.last_uploads_rows
    uploads = Upload.last_uploads(true).to_a
    upload_csv_types = uploads.map(&:csv_type)

    # add csv types that are missing from database to allow for uploads
    UPLOAD_TYPES_ALL_NAMES.each do |klass_name|
      next if upload_csv_types.include?(klass_name)

      missing_upload = Upload.new
      missing_upload.csv_type = klass_name
      missing_upload.ok = false
      missing_upload.comment = 'No initial file uploaded!!!'

      uploads.push(missing_upload)
    end

    uploads.sort_by { |upload| upload.csv_type.downcase }
  end

  def self.since_last_version
    last_version = Version.current_production

    return Upload.last_uploads if last_version.blank?

    Upload.last_uploads.where('updated_at > ?', last_version.updated_at)
  end

  def self.from_csv_type(csv_type)
    upload = Upload.new(csv_type: csv_type)
    upload.skip_lines = Common::Shared.file_type_defaults(csv_type)[:skip_lines]

    upload
  end

  def self.fetching_for?(csv_type)
    Upload.where(ok: false, completed_at: nil, csv_type: csv_type).any?
  end

  def self.unlock_fetches
    where(ok: false).update(ok: true)
  end

  def self.locked_fetches_exist?
    where(ok: false).any?
  end
end

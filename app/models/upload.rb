# frozen_string_literal: true

class Upload < ApplicationRecord
  attr_accessor :skip_lines, :upload_file, :upload_files

  belongs_to :user, inverse_of: :versions

  validates_associated :user
  validates :user_id, presence: true

  validates :csv, presence: true

  validate :csv_type_check?

  after_initialize :derive_dependent_columns, unless: :persisted?

  before_create :check_async_queue, if: :async_enabled?

  after_save :normalize_lcpe!, if: %i[ok? lcpe_normalizable?]

  def derive_dependent_columns
    self.csv ||= upload_file.try(:original_filename)
  end

  def ok?
    ok
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

  # Reassemble file after successive #create_async requests
  def create_or_concat_body
    File.open(upload_file.tempfile.path, 'rb') do
      new_body = upload_file.tempfile.read
      updated_body = body ? body.concat(new_body) : new_body
      update(body: updated_body)
    end
  ensure
    upload_file.tempfile.close
    upload_file.tempfile.unlink
  end

  # Upload has been queued for async processing and hasn't been completed or canceled
  def active?
    queued_at.present? && completed_at.blank? && canceled_at.blank?
  end

  def inactive?
    !active?
  end

  def cancel!
    return false if inactive?

    update(canceled_at: Time.now.utc.to_fs(:db), body: nil, status_message: nil)
  end

  def rollback_if_inactive
    raise ActiveRecord::Rollback, 'Upload no longer active' if reload.inactive?
  end

  # Update status in new thread to make updates readable from inside a database transaction
  def safely_update_status!(message)
    rollback_if_inactive

    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        update(status_message: message)
      end
    end
  end

  def update_import_progress!(completed, total)
    percent_complete = (completed.to_f / total) * 100
    safely_update_status!("importing records: #{percent_complete.round}% . . .")
  end

  def alerts
    data = status_message && JSON.parse(status_message)
    return {} unless data.is_a?(Hash)

    data.deep_symbolize_keys!
  rescue StandardError
    {}
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

  def self.async_queue
    select(&:active?)
  end

  private

  def check_async_queue
    return unless active_upload_of_same_csv_type?

    error_msg = "#{csv_type} file upload already in progress. Wait for upload to finish or cancel upload"
    raise StandardError, error_msg
  end

  def active_upload_of_same_csv_type?
    Upload.async_queue.pluck(:csv_type).include?(csv_type)
  end

  # Returns false if the `csv_type` cannot be mapped to `Lcpe::BlahBlahBlah` with a `normalize` method.
  def lcpe_normalizable?
    top_most = csv_type&.split('::')&.first&.constantize
    subject = csv_type&.constantize

    top_most == Lcpe && subject.respond_to?(:normalize)
  rescue StandardError
    nil
  end

  def normalize_lcpe!
    subject = csv_type&.constantize

    subject.normalize.execute
  rescue StandardError
    nil
  end
end

# frozen_string_literal: true

class Upload < ApplicationRecord
  attr_accessor :skip_lines, :upload_file

  belongs_to :user, inverse_of: :versions

  validates_associated :user
  validates :user_id, presence: true

  validates :csv, presence: true

  validate :csv_type_check?

  after_initialize :derive_dependent_columns, unless: :persisted?

  def derive_dependent_columns
    self.csv ||= upload_file.try(:original_filename)
  end

  def ok?
    ok
  end

  def csv_type_check?
    return true if [*UPLOAD_TYPES_ALL_NAMES, 'Institution'].include?(csv_type)

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

  def self.last_uploads
    Upload.select('DISTINCT ON("csv_type") *')
          .where(ok: true, csv_type: UPLOAD_TYPES_ALL_NAMES)
          .order(csv_type: :asc, updated_at: :desc)
  end

  def self.last_uploads_rows
    uploads = Upload.last_uploads.to_a
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

  def self.since_last_preview_version
    last_preview = Version.current_preview || Version.current_production

    return Upload.last_uploads if last_preview.blank?

    Upload.last_uploads.where('updated_at > ?', last_preview.updated_at)
  end

  def self.from_csv_type(csv_type)
    upload = Upload.new(csv_type: csv_type)
    upload.skip_lines = Common::Shared.file_type_defaults(csv_type)[:skip_lines]

    upload
  end

  def self.from_group_type(group_type)
    Upload.new(csv_type: group_type)
  end

  def self.fetching_for?(csv_type)
    Upload.where(ok: false, completed_at: nil, csv_type: csv_type).any?
  end
end

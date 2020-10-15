# frozen_string_literal: true

class Upload < ApplicationRecord
  attr_accessor :skip_lines, :col_sep, :upload_file

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
    return true if [*CSV_TYPES_ALL_TABLES_NAMES, 'Institution'].include?(csv_type)

    if csv_type.present?
      errors.add(:csv_type, "#{csv_type} is not a valid CSV data source")
    else
      errors.add(:csv_type, 'cannot be blank.')
    end

    false
  end

  def options
    { skip_lines: skip_lines.try(:to_i),
      col_sep: col_sep,
      force_simple_split: force_simple_split,
      strip_chars_from_headers: strip_chars_from_headers }
  end

  def force_simple_split
    self.class.default_options(csv_type)['force_simple_split']
  end

  def strip_chars_from_headers
    self.class.default_options(csv_type)['strip_chars_from_headers']
  end

  def self.last_uploads
    Upload.select('DISTINCT ON("csv_type") *')
          .where(ok: true, csv_type: CSV_TYPES_ALL_TABLES_NAMES)
          .order(csv_type: :asc, updated_at: :desc)
  end

  def self.last_uploads_rows
    uploads = Upload.last_uploads.to_a
    upload_csv_types = uploads.map(&:csv_type)

    # add csv types that are missing from database to allow for uploads
    CSV_TYPES_ALL_TABLES_NAMES.each do |klass_name|
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
    upload.skip_lines = default_options(csv_type)['skip_lines']
    upload.col_sep = default_options(csv_type)['col_sep']

    upload
  end

  def self.default_options(csv_type)
    Rails.application.config.csv_defaults[csv_type] || Rails.application.config.csv_defaults['generic']
  end

  def self.fetching_for?(csv_type)
    Upload.where(ok: false, completed_at: nil, csv_type: csv_type).any?
  end

  def self.valid_col_seps
    valid_col_seps = Settings.csv_upload.column_separators.each(&:to_s)
    { value: valid_col_seps, message: 'Valid column separators are:' }
  end
end

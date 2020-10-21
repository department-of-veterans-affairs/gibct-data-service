# frozen_string_literal: true

class Upload < ApplicationRecord
  attr_accessor :skip_lines, :col_sep, :upload_file, :missing_headers, :extra_headers

  belongs_to :user, inverse_of: :versions

  validates_associated :user
  validates :user_id, presence: true

  validates :csv, presence: true

  validate :csv_type_check?

  after_initialize :initialize_warnings, unless: :persisted?
  after_initialize :derive_dependent_columns, unless: :persisted?

  def derive_dependent_columns
    self.csv ||= upload_file.try(:original_filename)
  end

  def ok?
    ok
  end

  def all_warnings
    missing_headers.full_messages + extra_headers.full_messages
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

  def required_headers?
    upload_file && csv_type && skip_lines
  end

  def check_for_headers
    return unless required_headers?

    missing_headers.clear
    extra_headers.clear

    headers = diffed_headers
    headers[:missing_headers].each do |header|
      missing_headers.add(Common::Shared.export_csv_header(header).to_sym, 'is a missing header')
    end
    headers[:extra_headers].each do |header|
      extra_headers.add(Common::Shared.export_csv_header(header).to_sym, 'is an extra header')
    end
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

  private

  def initialize_warnings
    self.missing_headers = ActiveModel::Errors.new(self)
    self.extra_headers = ActiveModel::Errors.new(self)
  end

  def diffed_headers
    model_headers = csv_type.constantize::CSV_CONVERTER_INFO.keys
    file_headers = csv_file_headers

    { missing_headers: model_headers - file_headers, extra_headers: file_headers - model_headers }
  end

  def csv_file_headers
    csv = File.open(upload_file.tempfile, encoding: 'ISO-8859-1')
    skip_lines.to_i.times { csv.readline }

    first_line = csv.readline
    set_col_sep(first_line)

    first_line.split(col_sep).select(&:present?).map do |header|
      Common::Shared.convert_csv_header(header.downcase.strip)
    end
  end

  def set_col_sep(first_line)
    self.col_sep = Settings.csv_upload.column_separators
                           .find { |column_separator| first_line.include?(column_separator) }
    valid_col_seps = Upload.valid_col_seps[:value].map { |cs| "\"#{cs}\"" }.join(' and ')
    error_message = "Unable to determine column separators, valid separators equal #{valid_col_seps}"
    raise(StandardError, error_message) if col_sep.blank?
  end
end

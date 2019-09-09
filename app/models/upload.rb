# frozen_string_literal: true

class Upload < ActiveRecord::Base
  attr_accessor :skip_lines, :upload_file, :missing_headers, :extra_headers

  belongs_to :user, inverse_of: :versions

  validates_associated :user
  validates :user_id, presence: true

  validates :csv, presence: true

  validate :csv_type_check?

  after_initialize :initialize_warnings, unless: :persisted?
  after_initialize :derive_dependent_columns, unless: :persisted?

  def derive_dependent_columns
    self.csv = upload_file.try(:original_filename)
  end

  def ok?
    ok
  end

  def all_warnings
    missing_headers.full_messages + extra_headers.full_messages
  end

  def csv_type_check?
    return true if CSV_TYPES_ALL_TABLES.map(&:name).push('Institution').include?(csv_type)

    if csv_type.present?
      errors.add(:csv_type, "#{csv_type} is not a valid CSV data source")
    else
      errors.add(:csv_type, 'cannot be blank.')
    end

    false
  end

  def check_for_headers
    return unless upload_file && csv_type && skip_lines

    missing_headers.clear
    extra_headers.clear

    headers = diffed_headers
    headers[:missing_headers].each { |header| missing_headers.add(header.to_sym, 'is a missing header') }
    headers[:extra_headers].each { |header| extra_headers.add(header.to_sym, 'is an extra header') }
  end

  def self.last_uploads
    Upload.select('DISTINCT ON("csv_type") *').where(ok: true).order(csv_type: :asc).order(updated_at: :desc)
  end

  def self.last_uploads_rows
    uploads = Upload.last_uploads.to_a
    upload_csv_types = uploads.map(&:csv_type)

    # add csv types that are missing from database to allow for uploads
    CSV_TYPES_ALL_TABLES.each do |klass|
      next if upload_csv_types.include?(klass.name)
      missing_upload = Upload.new
      missing_upload.csv_type = klass.name
      missing_upload.ok = false
      missing_upload.comment = 'No initial file uploaded!!!'

      uploads.push(missing_upload)
    end

    uploads.sort_by { |upload| upload.csv_type.downcase }
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
    csv = CSV.open(upload_file.tempfile, return_headers: true, encoding: 'ISO-8859-1')
    skip_lines.to_i.times { csv.readline }

    (csv.readline || []).select(&:present?).map { |header| header.downcase.strip }
  end
end

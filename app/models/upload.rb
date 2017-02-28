# frozen_string_literal: true
class Upload < ActiveRecord::Base
  attr_accessor :skip_lines, :upload_file

  belongs_to :user, inverse_of: :versions

  validates_associated :user
  validates :user_id, presence: true

  validates :csv, presence: true
  validates :csv_type, inclusion: {
    in: InstitutionBuilder::TABLES.map(&:name),
    message: '%{value} is not a valid CSV type'
  }

  after_initialize :derive_dependent_columns, unless: :persisted?

  def ok?
    ok
  end

  def derive_dependent_columns
    self.csv = upload_file.try(:original_filename)
  end

  def self.last_uploads
    max_query = Upload.select('csv_type, MAX(updated_at) as max_updated_at').where(ok: true).group(:csv_type).to_sql

    joins("INNER JOIN (#{max_query}) max_uploads ON uploads.csv_type = max_uploads.csv_type")
      .where('uploads.updated_at = max_uploads.max_updated_at')
      .order(:csv_type)
  end
end

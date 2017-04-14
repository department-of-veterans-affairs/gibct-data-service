# frozen_string_literal: true
class Upload < ActiveRecord::Base
  attr_accessor :skip_lines, :upload_file

  belongs_to :user, inverse_of: :versions

  validates_associated :user
  validates :user_id, presence: true

  validates :csv, presence: true
  validate :csv_type_check?

  after_initialize :derive_dependent_columns, unless: :persisted?

  def ok?
    ok
  end

  def csv_type_check?
    return true if InstitutionBuilder::TABLES.map(&:name).push('Institution').include?(csv_type)

    errors.add(:csv_type, "#{csv_type} is not a valid CSV data source")
    false
  end

  def derive_dependent_columns
    self.csv = upload_file.try(:original_filename)
  end

  def self.last_uploads
    Upload.select('DISTINCT ON("csv_type") *').where(ok: true).order(csv_type: :asc).order(updated_at: :desc)
  end
end

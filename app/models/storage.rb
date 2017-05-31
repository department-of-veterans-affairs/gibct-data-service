# frozen_string_literal: true
class Storage < ActiveRecord::Base
  attr_accessor :upload_file

  belongs_to :user, inverse_of: :storages

  validates_associated :user
  validates :user_id, presence: true

  validates :csv_type, uniqueness: true, inclusion: { in: InstitutionBuilder::TABLES.map(&:name) }
  validates :data, :csv, :upload_file, presence: true

  after_initialize :derive_dependent_columns, unless: :persisted?
  after_initialize :read_file, unless: :persisted?

  private

  def derive_dependent_columns
    self.csv = upload_file.try(:original_filename)
  end

  def read_file
    self.data = File.read(upload_file.path, encoding: 'ISO-8859-1')
  rescue StandardError => e
    errors.add(:upload_file, "error reading the uploaded csv file: #{e.message}")
  end
end

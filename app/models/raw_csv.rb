# frozen_string_literal: true
class RawCsv < ActiveRecord::Base
  attr_accessor :csv_file

  validates :csv_type, inclusion: { in: InstitutionBuilder::TABLES.map(&:name) }
  validates :storage, :csv_file, presence: true

  after_initialize :read_file, unless: :persisted?

  private

  def read_file
    self.storage = csv_file.read
  rescue StandardError => e
    errors.add(:csv_file, "error reading the uploaded csv_file: #{e.message}")
  end
end

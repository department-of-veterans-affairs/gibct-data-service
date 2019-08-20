# frozen_string_literal: true

class Storage < ActiveRecord::Base
  attr_accessor :upload_file

  belongs_to :user, inverse_of: :storages

  validates_associated :user
  validates :user_id, presence: true

  validates :csv_type, uniqueness: true, inclusion: { in: CsvTypes.all_tables.map(&:name) }
  validates :data, :csv, presence: true
  validates :upload_file, presence: true, unless: :persisted?

  after_initialize :replace_data, unless: :persisted?

  def self.find_and_update(params)
    storage = Storage.find_by(id: params[:id])
    raise(ArgumentError, "Invalid Storage id: #{params[:id]}") if storage.blank?

    storage.upload_file = params[:upload_file]
    storage.user = params[:user]
    storage.comment = params[:comment] if params[:comment].present?

    storage.replace_data
    storage.save
    storage
  end

  def replace_data
    derive_dependent_columns
  end

  private

  def derive_dependent_columns
    self.csv = upload_file.try(:original_filename)
    self.data = File.read(upload_file.path, encoding: 'ISO-8859-1')
  rescue StandardError => e
    errors.add(:upload_file, "error reading the uploaded csv file: #{e.message}")
  end
end

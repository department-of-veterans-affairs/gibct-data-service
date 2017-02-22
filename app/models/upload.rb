# frozen_string_literal: true
class Upload < ActiveRecord::Base
  attr_accessor :skip_lines, :upload_file

  belongs_to :user, inverse_of: :versions

  validates_associated :user
  validates :user_id, presence: true

  validates :filename, presence: true
  validates :csv_type, inclusion: {
    in: InstitutionBuilder::TABLES.map(&:name),
    message: '%{value} is not a valid CSV type'
  }

  before_validation :derive_dependent_columns

  def derive_dependent_columns
    self.filename = upload_file.try(:original_filename)
  end
end

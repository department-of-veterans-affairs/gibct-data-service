# frozen_string_literal: true

class CalculatorConstantVersionsArchive < ApplicationRecord
  # TO-DO? Is it necessary to add foreign key and index to associate Version with CalculatorConstantVersionsArchive
  # So you can call Version.latest_from_year(year).calculator_constant_versions_archives
  # Will be frequent query when exporting calculator constant report
  scope :circa, ->(year) { where(version_id: Version.latest_from_year(year)&.id) }

  validates :name, uniqueness: { scope: :version_id }, presence: true, inclusion: { in: CalculatorConstant::CONSTANT_NAMES }
  validates :float_value, presence: true
end

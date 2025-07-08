# frozen_string_literal: true

class CalculatorConstantVersionsArchive < ApplicationRecord
  belongs_to :version

  validates :name, uniqueness: { scope: :version_id }, presence: true
  validates :float_value, presence: true

  # If you plug current year into :circa, you will always get empty collection
  # because latest CalculatorConstantVersion has yet to be archived, which is desired behavior
  scope :circa, ->(year) { where(version: Version.latest_from_year(year)) }
end

# frozen_string_literal: true

class CalculatorConstantVersionsArchive < ApplicationRecord
  include ArchiveVersionable

  SOURCE_TABLE = CalculatorConstantVersion

  belongs_to :version

  validates :name, uniqueness: { scope: :version_id }, presence: true
  validates :float_value, presence: true
end

# frozen_string_literal: true

class CalculatorConstantVersion < ApplicationRecord
  belongs_to :version

  validates :name, uniqueness: { scope: :version_id }, presence: true
  validates :float_value, presence: true
end

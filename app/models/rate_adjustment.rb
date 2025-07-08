# frozen_string_literal: true

class RateAdjustment < ApplicationRecord
  has_many :calculator_constants, dependent: :nullify

  validates :benefit_type, presence: true, uniqueness: true, numericality: { greater_than: 0 }
  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
end

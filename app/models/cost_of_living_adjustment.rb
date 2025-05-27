# frozen_string_literal: true

class CostOfLivingAdjustment < ApplicationRecord
  has_many :calculator_constants, dependent: :nullify

  BENEFIT_TYPES = %w[30 33 35 1606].freeze

  validates :benefit_type, presence: true, uniqueness: true, inclusion: { in: BENEFIT_TYPES }
  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
end

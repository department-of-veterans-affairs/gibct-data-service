# frozen_string_literal: true

class CostOfLivingAdjustment < ApplicationRecord
  has_many :calculator_constants, dependent: :nullify

  BENEFIT_TYPES = %w[30 33 35 1606].freeze

  validates :benefit_type, uniqueness: true, inclusion: { in: BENEFIT_TYPES }
end

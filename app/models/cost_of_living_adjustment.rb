# frozen_string_literal: true

class CostOfLivingAdjustment < ApplicationRecord
  has_many :calculator_constants, dependent: :nullify

  after_commit -> { broadcast_refresh_later_to 'cost_of_living_adjustments' }

  BENEFIT_TYPES = %w[30 33 35 1606].sort_by(&:to_i).freeze

  validates :benefit_type, presence: true, uniqueness: true, inclusion: { in: BENEFIT_TYPES }
  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # assumes all benefit types can be converted to integer
  scope :by_chapter_number, -> { sort_by { |cola| cola.benefit_type.to_i } }
end

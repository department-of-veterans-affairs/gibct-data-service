# frozen_string_literal: true

class RateAdjustment < ApplicationRecord
  has_many :calculator_constants, dependent: :nullify

  # Benefit type to always be an integer that corresponds with chapter number, e.g. Chapter 33
  validates :benefit_type, presence: true, uniqueness: true, numericality: { greater_than: 0 }
  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :by_chapter_number, -> { order(:benefit_type) }

  def chapterize
    "Ch. #{benefit_type}"
  end
end

# frozen_string_literal: true

class RateAdjustment < ApplicationRecord
  has_many :calculator_constants, dependent: :nullify

  def chapterize
    "Ch. #{benefit_type}"
  end
end

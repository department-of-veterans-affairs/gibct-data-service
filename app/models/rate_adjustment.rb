# frozen_string_literal: true

class RateAdjustment < ApplicationRecord
  has_many :calculator_constants, dependent: :nullify
end
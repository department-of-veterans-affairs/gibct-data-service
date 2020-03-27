# frozen_string_literal: true

class CautionFlagRule < ApplicationRecord
  has_one :rule
  validates :rule, presence: true
end

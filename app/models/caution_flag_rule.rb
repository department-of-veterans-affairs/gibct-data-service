# frozen_string_literal: true

class CautionFlagRule < ApplicationRecord
  has_one :rule, dependent: :nullify
  validates :rule, presence: true
end

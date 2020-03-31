# frozen_string_literal: true

class CautionFlagRule < ApplicationRecord
  belongs_to :rule
  validates :rule, presence: true
end

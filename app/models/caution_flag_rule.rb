# frozen_string_literal: true

class CautionFlagRule < ApplicationRecord
  belongs_to :rule

  SCHOOL_URL = 'SCHOOL_URL'.freeze

  validates :rule, presence: true
end

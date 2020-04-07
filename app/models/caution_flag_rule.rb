# frozen_string_literal: true

class CautionFlagRule < ApplicationRecord
  belongs_to :rule

  SCHOOL_URL = 'SCHOOL_URL'

  validates :rule, presence: true
end

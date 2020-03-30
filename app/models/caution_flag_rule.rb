# frozen_string_literal: true

class CautionFlagRule < ApplicationRecord
  SOURCES = [
      AccreditationAction.name,
      Settlement.name,
      Hcm.name,
      Mou.name,
      Sec702.name
  ].freeze

  belongs_to :rule
  validates :rule, :source, presence: true
  validates :source, inclusion: { in: SOURCES }
end

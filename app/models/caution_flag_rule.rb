# frozen_string_literal: true

class CautionFlagRule < ApplicationRecord
  COLS_USED_IN_UPDATE = %i[
    title description link_text link_url
  ].freeze

  has_one :rule, dependent: :nullify
  validates :rule, presence: true
end

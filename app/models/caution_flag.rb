# frozen_string_literal: true

class CautionFlag < ApplicationRecord
  SOURCES = {
    accreditation_action: 'accreditation_action',
    mou: 'mou',
    sec_702: 'sec_702',
    settlement: 'settlement',
  }.freeze
end

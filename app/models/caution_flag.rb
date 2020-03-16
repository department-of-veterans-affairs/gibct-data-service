# frozen_string_literal: true

class CautionFlag < ApplicationRecord
  SOURCES = {
    accreditation_action: 'accreditation_action',
    mou: 'mou'
  }.freeze
end

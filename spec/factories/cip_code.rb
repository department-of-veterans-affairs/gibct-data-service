# frozen_string_literal: true

FactoryBot.define do
  factory :cip_code do
    cip_family { '01' }
    cip_code { '01.0103' }
    action { 'No substantive changes' }
    text_change { false }
    cip_title { 'AGRICULTURE, AGRICULTURE OPERATIONS, AND RELATED SCIENCES.' }
    cip_definition { 'AGRICULTURE defined' }
    cross_references { '14.0301 - Agricultural Engineering.' }
    examples { 'Examples: - Agricultural Systems Management' }
  end
end

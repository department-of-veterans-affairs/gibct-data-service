# frozen_string_literal: true

FactoryBot.define do
  factory :accreditation_action do
    dapip_id 131_584
    agency_id 1
    agency_name 'MIDDLE STATES COMMISSION ON HIGHER EDUCATION'
    program_id 1
    program_name 'Institutional Accreditation'
    sequential_id 1
    action_description 'Renewal of Accreditation'
    action_date '2019-01-07'
    justification_description "Is in compliance with all of the agency's accreditation standards"

    factory :accreditation_action_probationary do
      action_description 'Probation or Equivalent or a More Severe Status: Probation'
      action_date '2019-01-08'
      justification_description 'Significantly out of compliance - student achievement'
    end
  end
end

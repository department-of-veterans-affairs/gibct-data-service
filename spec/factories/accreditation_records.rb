# frozen_string_literal: true

FactoryBot.define do
  factory :accreditation_record do
    dapip_id { 131_584 }
    agency_id { 1 }
    agency_name { 'MIDDLE STATES COMMISSION ON HIGHER EDUCATION' }
    program_id { 1 }
    program_name { 'Institutional Accreditation' }
    sequential_id { 1 }
    initial_date_flag { 'Estimated' }
    accreditation_date { '1957-07-01' }
    accreditation_status { 'Accredited' }
    review_date { '2024-12-31' }
    accreditation_end_date { nil }

    factory :accreditation_record_expired do
      accreditation_end_date { '2000-01-01' }
    end

    factory :regional_accreditation_type do
      agency_name { 'NORTHWEST COMMISSION ON COLLEGES AND UNIVERSITIES' }
    end

    factory :national_accreditation_type do
      agency_name { 'ACCREDITING COMMISSION OF CAREER SCHOOLS AND COLLEGES' }
    end

    factory :hybrid_accreditation_type do
      agency_name { 'MIDWIFERY EDUCATION ACCREDITATION COUNCIL' }
    end

    factory :nil_accreditation_type do
      agency_name { 'TRUMP U' }
    end

    initialize_with do
      new(attributes)
    end
  end
end

# frozen_string_literal: true
class InstitutionSerializer < ActiveModel::Serializer
  SELECT_FIELDS = %i(
    id institution facility_code institution_type_name city state zip country
    locale gibill caution_flag caution_flag_reason created_at updated_at
    bah tuition_in_state tuition_out_of_state books insturl cross
    student_veteran yr poe eight_keys
  ).freeze

  attribute :institution
  attribute :facility_code
  attribute :institution_type_name, key: :type
  attribute :city
  attribute :state
  attribute :zip
  attribute :country
  attribute :locale
  attribute :gibill, key: :student_count
  attribute :caution_flag, if: -> { object.caution_flag.present? }
  attribute :caution_flag_reason, if: -> { object.caution_flag.present? }
  attribute :created_at
  attribute :updated_at

  attribute :bah
  attribute :tuition_in_state
  attribute :tuition_out_of_state
  attribute :books

  attribute :student_veteran
  attribute :yr
  attribute :poe
  attribute :eight_keys

  link :website do
    "http://#{object.insturl}" if object.insturl.present?
  end

  link :scorecard do
    if object.school? && object.cross.present?
      [
        "https://collegescorecard.ed.gov/school/?#{object.cross}",
        object.institution.downcase.parameterize
      ].join('-')
    end
  end

  link :self do
    v0_institution_url(object.facility_code)
  end
end

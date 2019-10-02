# frozen_string_literal: true

class InstitutionProgramSerializer < ActiveModel::Serializer
  attribute :program_type
  attribute :description
  attribute :full_time_undergraduate
  attribute :graduate
  attribute :full_time_modifier
  attribute :length_in_hours
  attribute :school_locale
  attribute :provider_website
  attribute :provider_email_address
  attribute :phone_area_code
  attribute :phone_number
  attribute :student_vet_group
  attribute :student_vet_group_website
  attribute :vet_success_name
  attribute :vet_success_email
  attribute :tuition_amount
  attribute :length_in_weeks
  attribute :facility_code
  attribute :institution_name
  attribute :institution_city
  attribute :institution_state
  attribute :institution_country
  attribute :preferred_provider
end

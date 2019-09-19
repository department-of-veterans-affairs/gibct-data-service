# frozen_string_literal: true

class InstitutionProgramSerializer < ActiveModel::Serializer
  attribute :program_type
  attribute :description
  attribute :full_time_undergraduate
  attribute :graduate
  attribute :full_time_modifier
  attribute :length
  attribute :school_locale
  attribute :provider_website
  attribute :provider_email_address
  attribute :phone_area_code
  attribute :phone_number
  attribute :student_vet_group
  attribute :student_vet_group_website
  attribute :vet_success_name
  attribute :tuition_amount
  attribute :program_length
end

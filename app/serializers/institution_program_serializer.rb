# frozen_string_literal: true

class InstitutionProgramSerializer < ActiveModel::Serializer
  attribute :program_type
  attribute :description
  attribute :length_in_hours
  attribute :facility_code
  attribute :institution_name
  attribute :city
  attribute :state
  attribute :country
  attribute :preferred_provider
  attribute :tuition_amount
  attribute :va_bah
  attribute :dod_bah
end

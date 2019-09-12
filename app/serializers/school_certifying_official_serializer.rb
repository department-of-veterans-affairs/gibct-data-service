# frozen_string_literal: true

class SchoolCertifyingOfficialSerializer < ActiveModel::Serializer
  attribute :facility_code
  attribute :institution_name
  attribute :priority
  attribute :first_name
  attribute :last_name
  attribute :title
  attribute :phone_area_code
  attribute :phone_number
  attribute :phone_extension
  attribute :email
end

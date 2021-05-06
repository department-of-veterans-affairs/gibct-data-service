# frozen_string_literal: true

class InstitutionSearchResultSerializer < ActiveModel::Serializer
  attribute :institution, key: :name
  attribute :facility_code
  attribute :city
  attribute :state
  attribute :accreditation_type
  attribute :gibill, key: :student_count
  attribute :rating_average
  attribute :rating_count
  attribute :institution_type_name, key: :type
  attribute :country
  attribute :caution_flags
  attribute :count_of_caution_flags
  attribute :student_veteran
  attribute :yr
  attribute :campus_type
  attribute :highest_degree
  attribute :hbcu
  attribute :menonly
  attribute :womenonly
  attribute :relaffil
  attribute :preferred_provider
end

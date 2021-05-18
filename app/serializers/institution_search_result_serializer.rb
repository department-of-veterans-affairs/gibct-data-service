# frozen_string_literal: true

class InstitutionSearchResultSerializer < ActiveModel::Serializer
  attribute :institution, key: :name
  attribute :facility_code
  attribute :physical_city, key: :city
  attribute :physical_state, key: :state
  attribute :physical_country, key: :country
  attribute :accreditation_type
  attribute :gibill, key: :student_count
  attribute :rating_average
  attribute :rating_count
  attribute :institution_type_name, key: :type
  attribute :caution_flags
  attribute :caution_flag
  attribute :student_veteran
  attribute :yr
  attribute :campus_type
  attribute :highest_degree
  attribute :hbcu
  attribute :menonly
  attribute :womenonly
  attribute :relaffil
  attribute :preferred_provider
  attribute :latitude
  attribute :longitude
  attribute :distance

  def caution_flags
    object.caution_flags.map do |flag|
      CautionFlagSerializer.new(flag)
    end
  end
end

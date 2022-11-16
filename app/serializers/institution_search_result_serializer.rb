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
  attribute :hsi
  attribute :nanti
  attribute :annhi
  attribute :aanapii
  attribute :pbi
  attribute :tribal
  attribute :preferred_provider
  attribute :dod_bah
  attribute :bah
  attribute :latitude
  attribute :longitude
  attribute :distance
  attribute :accredited
  attribute :vet_tec_provider
  attribute :program_count
  attribute :program_length_in_hours
  attribute :school_provider
  attribute :employer_provider
  attribute :vrrap

  link(:self) { v0_institution_url(object.facility_code) }

  def caution_flags
    return [] unless object.caution_flag

    object.caution_flags.map do |flag|
      CautionFlagSerializer.new(flag)
    end
  end

  def program_count
    object.institution_programs.count if object.vet_tec_provider
  end

  def program_length_in_hours
    object.institution_programs.map(&:length_in_hours) if object.vet_tec_provider
  end
end

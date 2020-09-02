# frozen_string_literal: true

class InstitutionSerializer < ActiveModel::Serializer
  SELECT_FIELDS = %i[
    id institution facility_code ialias institution_type_name city state zip country
    locale gibill caution_flag caution_flag_reason created_at updated_at
    bah tuition_in_state tuition_out_of_state books insturl cross
    student_veteran yr poe eight_keys stem_offered independent_study priority_enrollment
  ].freeze

  attribute :institution, key: :name
  attribute :facility_code
  attribute :ialias, key: 'alias'
  attribute :institution_type_name, key: :type
  attribute :city
  attribute :state
  attribute :zip
  attribute :country
  attribute :highest_degree
  attribute :locale_type
  attribute :gibill, key: :student_count
  attribute :caution_flag
  attribute :caution_flag_reason
  attribute :caution_flags
  attribute :created_at
  attribute :updated_at
  attribute :address_1
  attribute :address_2
  attribute :address_3
  attribute :physical_city
  attribute :physical_state
  attribute :physical_country
  attribute :online_only
  attribute :distance_learning
  attribute :dod_bah
  attribute :physical_zip

  attribute :bah
  attribute :tuition_in_state
  attribute :tuition_out_of_state
  attribute :books

  attribute :student_veteran
  attribute :yr
  attribute :poe
  attribute :eight_keys
  attribute :stem_offered
  attribute :independent_study
  attribute :priority_enrollment

  attribute :school_closing
  attribute :school_closing_on
  attribute :closure109
  attribute :vet_tec_provider
  attribute :parent_facility_code_id
  attribute :campus_type

  attribute :preferred_provider
  attribute :count_of_caution_flags

  attribute :hbcu
  attribute :hcm2
  attribute :menonly
  attribute :pctfloan
  attribute :relaffil
  attribute :womenonly

  link(:website) { object.website_link }
  link(:scorecard) { object.scorecard_link }
  link(:self) { v0_institution_url(object.facility_code) }
end

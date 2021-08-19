# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class InstitutionProfileSerializer < ActiveModel::Serializer
  attribute :institution, key: :name
  attribute :facility_code
  attribute :institution_type_name, key: :type
  attribute :city
  attribute :state
  attribute :zip
  attribute :country
  attribute :bah
  attribute :cross
  attribute :flight
  attribute :correspondence
  attribute :ope
  attribute :ope6
  attribute :f1sysnam, key: :school_system_name
  attribute :f1syscod, key: :school_system_code
  attribute :ialias, key: :alias
  attribute :highest_degree
  attribute :locale_type
  attribute :address_1
  attribute :address_2
  attribute :address_3
  attribute :gibill, key: :student_count
  attribute :undergrad_enrollment
  attribute :yr
  attribute :student_veteran
  attribute :student_veteran_link
  attribute :poe
  attribute :eight_keys
  attribute :stem_offered
  attribute :dodmou
  attribute :sec_702
  attribute :vetsuccess_name, key: :vet_success_name
  attribute :vetsuccess_email, key: :vet_success_email
  attribute :credit_for_mil_training
  attribute :vet_poc
  attribute :student_vet_grp_ipeds
  attribute :soc_member
  attribute :retention_rate_veteran_ba
  attribute :retention_all_students_ba
  attribute :retention_rate_veteran_otb
  attribute :retention_all_students_otb
  attribute :persistance_rate_veteran_ba
  attribute :persistance_rate_veteran_otb
  attribute :graduation_rate_veteran
  attribute :graduation_rate_all_students
  attribute :transfer_out_rate_veteran
  attribute :transfer_out_rate_all_students
  attribute :salary_all_students
  attribute :repayment_rate_all_students
  attribute :avg_stu_loan_debt
  attribute :calendar
  attribute :tuition_in_state
  attribute :tuition_out_of_state
  attribute :books
  attribute :online_all
  attribute :p911_tuition_fees
  attribute :p911_recipients
  attribute :p911_yellow_ribbon
  attribute :p911_yr_recipients
  attribute :accredited
  attribute :accreditation_type
  attribute :accreditation_status
  attribute :caution_flag
  attribute :caution_flag_reason
  attribute :caution_flags
  attribute(:complaints) { object.complaints }
  attribute :school_closing
  attribute :school_closing_on
  attribute :school_closing_message
  attribute :yellow_ribbon_programs
  attribute :independent_study
  attribute :priority_enrollment
  attribute :created_at
  attribute :updated_at
  attribute :physical_address_1
  attribute :physical_address_2
  attribute :physical_address_3
  attribute :physical_city
  attribute :physical_state
  attribute :physical_country
  attribute :online_only
  attribute :distance_learning
  attribute :dod_bah
  attribute :physical_zip
  attribute :parent_facility_code_id
  attribute :campus_type
  attribute :vet_tec_provider
  attribute :preferred_provider
  attribute :stem_indicator
  attribute :facility_map
  attribute :programs
  attribute :versioned_school_certifying_officials
  attribute :count_of_caution_flags
  attribute :section_103_message
  attribute :hbcu
  attribute :hcm2
  attribute :menonly
  attribute :pctfloan
  attribute :relaffil
  attribute :womenonly
  attribute :institution_category_ratings
  attribute :rating_average
  attribute :rating_count
  attribute :in_state_tuition_information
  attribute :vrrap

  link(:website) { object.website_link }
  link(:scorecard) { object.scorecard_link }
  link(:vet_website_link) { object.vet_website_link }
  link(:self) { v0_institution_url(object.facility_code) }
  def yellow_ribbon_programs
    object.yellow_ribbon_programs.map do |yrp|
      YellowRibbonProgramSerializer.new(yrp)
    end
  end

  def versioned_school_certifying_officials
    object.versioned_school_certifying_officials.select do |sco|
      VersionedSchoolCertifyingOfficialSerializer.new(sco)
    end
  end

  def programs
    return [] unless object.vet_tec_provider

    object.institution_programs.map do |program|
      InstitutionProgramProfileSerializer.new(program)
    end
  end

  def caution_flags
    return [] unless object.caution_flag

    object.caution_flags.map do |flag|
      CautionFlagSerializer.new(flag)
    end
  end
end
# rubocop:enable Metrics/ClassLength

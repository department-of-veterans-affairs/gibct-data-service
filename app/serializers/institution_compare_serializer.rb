# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class InstitutionCompareSerializer < ActiveModel::Serializer
  attribute :institution, key: :name
  attribute :facility_code
  attribute :physical_city, key: :city
  attribute :physical_state, key: :state
  attribute :physical_zip, key: :zip
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
  attribute :dod_bah
  attribute :bah
  attribute :accredited
  attribute :vet_tec_provider

  attribute :flight
  attribute :correspondence
  attribute :f1sysnam, key: :school_system_name
  attribute :f1syscod, key: :school_system_code
  attribute :locale_type
  attribute :undergrad_enrollment
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
  attribute :accreditation_status
  attribute(:complaints) { object.complaints }
  attribute :school_closing
  attribute :school_closing_on
  attribute :school_closing_message
  attribute :yellow_ribbon_programs
  attribute :independent_study
  attribute :priority_enrollment
  attribute :created_at
  attribute :updated_at
  attribute :online_only
  attribute :distance_learning
  attribute :stem_indicator
  attribute :section_103_message
  attribute :hcm2
  attribute :pctfloan
  attribute :institution_category_ratings

  def yellow_ribbon_programs
    object.yellow_ribbon_programs.map do |yrp|
      YellowRibbonProgramSerializer.new(yrp)
    end
  end

  def caution_flags
    object.caution_flags.map do |flag|
      CautionFlagSerializer.new(flag)
    end
  end
end
# rubocop:enable Metrics/ClassLength

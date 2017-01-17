# frozen_string_literal: true
class InstitutionProfileSerializer < ActiveModel::Serializer
  include OptionalSerializedAttributes

  attribute :institution
  attribute :facility_code
  attribute :institution_type_name, key: :type
  attribute :city
  attribute :state
  attribute :zip
  attribute :country
  attribute :bah
  attribute :cross
  attribute :ope
  attribute :pred_degree_awarded
  attribute :locale
  attribute :gibill, key: :student_count
  attribute :undergrad_enrollment
  attribute :yr
  attribute :student_veteran
  attribute :student_veteran_link
  attribute :poe
  attribute :eight_keys
  attribute :dodmou
  attribute :sec_702
  attribute :vetsuccess_name
  attribute :vetsuccess_email
  attribute :credit_for_mil_training
  attribute :vet_poc
  attribute :student_vet_grp_ipeds
  attribute :soc_member
  attribute :va_highest_degree_offered
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
  attribute :caution_flag, if: -> { object.caution_flag.present? }
  attribute :caution_flag_reason, if: -> { object.caution_flag.present? }
  attribute_if_positive :complaints_facility_code
  attribute_if_positive :complaints_financial_by_fac_code
  attribute_if_positive :complaints_quality_by_fac_code
  attribute_if_positive :complaints_refund_by_fac_code
  attribute_if_positive :complaints_marketing_by_fac_code
  attribute_if_positive :complaints_accreditation_by_fac_code
  attribute_if_positive :complaints_degree_requirements_by_fac_code
  attribute_if_positive :complaints_student_loans_by_fac_code
  attribute_if_positive :complaints_grades_by_fac_code
  attribute_if_positive :complaints_credit_transfer_by_fac_code
  attribute_if_positive :complaints_credit_job_by_fac_code
  attribute_if_positive :complaints_job_by_fac_code
  attribute_if_positive :complaints_transcript_by_fac_code
  attribute_if_positive :complaints_other_by_fac_code
  attribute_if_positive :complaints_main_campus_roll_up
  attribute_if_positive :complaints_financial_by_ope_id_do_not_sum
  attribute_if_positive :complaints_quality_by_ope_id_do_not_sum
  attribute_if_positive :complaints_refund_by_ope_id_do_not_sum
  attribute_if_positive :complaints_marketing_by_ope_id_do_not_sum
  attribute_if_positive :complaints_accreditation_by_ope_id_do_not_sum
  attribute_if_positive :complaints_degree_requirements_by_ope_id_do_not_sum
  attribute_if_positive :complaints_student_loans_by_ope_id_do_not_sum
  attribute_if_positive :complaints_grades_by_ope_id_do_not_sum
  attribute_if_positive :complaints_credit_transfer_by_ope_id_do_not_sum
  attribute_if_positive :complaints_jobs_by_ope_id_do_not_sum
  attribute_if_positive :complaints_transcript_by_ope_id_do_not_sum
  attribute_if_positive :complaints_other_by_ope_id_do_not_sum
  attribute :created_at
  attribute :updated_at

  link :website do
    "http://#{object.insturl}" if object.insturl.present?
  end

  link :vet_tuition_policy_url do
    "http://#{object.vet_tuition_policy_url}" if object.vet_tuition_policy_url.present?
  end

  link :scorecard do
    "https://collegescorecard.ed.gov/school/?#{object.cross}-#{object.institution.downcase.parameterize}"
  end

  link :self do
    v0_institution_url(object.facility_code)
  end
end

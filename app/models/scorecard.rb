class Scorecard < ActiveRecord::Base
  include Standardizable

  validates :ope, presence: true
  validates :ope6, presence: true
  validates :cross, presence: true
  validates :pred_degree_awarded, numericality: true, allow_blank: true
  validates :locale, numericality: { only_integer: true }, allow_blank: true
  validates :undergrad_enrollment, numericality: true, allow_blank: true
  validates :retention_all_students_ba, numericality: true, allow_blank: true
  validates :retention_all_students_otb, numericality: true, allow_blank: true
  validates :graduation_rate_all_students, numericality: true, allow_blank: true
  validates :salary_all_students, numericality: true, allow_blank: true
  validates :repayment_rate_all_students, numericality: true, allow_blank: true
  validates :avg_stu_loan_debt, numericality: true, allow_blank: true
  validates :c150_4_pooled_supp, numericality: true, allow_blank: true
  validates :c200_l4_pooled_supp, numericality: true, allow_blank: true

  before_save :set_derived_fields

  USE_COLUMNS = [
    :insturl, :pred_degree_awarded, :locale, :undergrad_enrollment,
    :retention_all_students_ba, :retention_all_students_otb,
    :graduation_rate_all_students, :transfer_out_rate_all_students,
    :salary_all_students, :repayment_rate_all_students, :avg_stu_loan_debt
  ]

  # #############################################################################
  # ## ope=
  # ## Strips whitespace and sets value to downcase, and pads ope with 0s
  # #############################################################################
  # def ope=(value)
  #   value = value.try(:strip).try(:downcase)
  #   value = nil if value.blank? || value == 'none' 

  #   write_attribute(:ope, DS::OpeId.pad(value))
  # end

  # #############################################################################
  # ## cross=
  # ## Strips whitespace and sets value to downcase, and pads ipeds with 0s
  # #############################################################################
  # def cross=(value)
  #   value = value.try(:strip).try(:downcase)
  #   value = nil if value.blank? || value == 'none' 

  #   write_attribute(:cross, DS::IpedsId.pad(value))
  # end

  # #############################################################################
  # ## pred_degree_awarded=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def pred_degree_awarded=(value)
  #   value = nil if !DS::Number.is_i?(value)

  #   write_attribute(:pred_degree_awarded, value)
  # end

  # #############################################################################
  # ## locale=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def locale=(value)
  #   value = nil if !DS::Number.is_i?(value)

  #   write_attribute(:locale, value)
  # end

  # #############################################################################
  # ## undergrad_enrollment=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def undergrad_enrollment=(value)
  #   value = nil if !DS::Number.is_i?(value)

  #   write_attribute(:undergrad_enrollment, value)
  # end
  
  # #############################################################################
  # ## retention_all_students_ba=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def retention_all_students_ba=(value)
  #   value = nil if !DS::Number.is_f?(value)

  #   write_attribute(:retention_all_students_ba, value)
  # end
  
  # #############################################################################
  # ## retention_all_students_otb=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def retention_all_students_otb=(value)
  #   value = nil if !DS::Number.is_f?(value)

  #   write_attribute(:retention_all_students_otb, value)
  # end

  # #############################################################################
  # ## transfer_out_rate_all_students=
  # ## Sets to nil and is not used in GIBCT
  # #############################################################################
  # def transfer_out_rate_all_students=(value)
  #   write_attribute(:transfer_out_rate_all_students, nil)
  # end

  # #############################################################################
  # ## salary_all_students=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def salary_all_students=(value)
  #   value = nil if !DS::Number.is_f?(value)

  #   write_attribute(:salary_all_students, value)
  # end

  # #############################################################################
  # ## repayment_rate_all_students=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def repayment_rate_all_students=(value)
  #   value = nil if !DS::Number.is_f?(value)

  #   write_attribute(:repayment_rate_all_students, value)
  # end

  # #############################################################################
  # ## avg_stu_loan_debt=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def avg_stu_loan_debt=(value)
  #   value = nil if !DS::Number.is_f?(value)

  #   write_attribute(:avg_stu_loan_debt, value)
  # end

  # #############################################################################
  # ## c150_4_pooled_supp=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def c150_4_pooled_supp=(value)
  #   value = nil if !DS::Number.is_f?(value)

  #   write_attribute(:c150_4_pooled_supp, value)
  # end

  # #############################################################################
  # ## c200_l4_pooled_supp=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def c200_l4_pooled_supp=(value)
  #   value = nil if !DS::Number.is_f?(value)

  #   write_attribute(:c200_l4_pooled_supp, value)
  # end

  #############################################################################
  ## to_graduation_rate_all_students
  #############################################################################
  def to_graduation_rate_all_students
    c150_4_pooled_supp.present? ? c150_4_pooled_supp : 
      c200_l4_pooled_supp.present? ? c200_l4_pooled_supp : nil
  end

  #############################################################################
  ## set_derived_fields=
  ## Computes the values of derived fields just prior to saving. Note that 
  ## any fields here cannot be part of validations.
  #############################################################################
  def set_derived_fields
    # self.ope6 = DS::OpeId.to_ope6(ope)
    self.graduation_rate_all_students = to_graduation_rate_all_students
  end
end

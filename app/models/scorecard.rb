###############################################################################
## Scorecard
## From the DOE, contains demographics and rates on a school by school basis.
##
## USE_COLUMNS hold those columns that get copied to the DataCsv table during
## the build process.
###############################################################################
class Scorecard < ActiveRecord::Base
  include Standardizable

  validates :ope, presence: true
  validates :ope6, presence: true
  validates :cross, presence: true
  validates :pred_degree_awarded, numericality: { message: '%{value} is not a number' }, allow_blank: true
  validates :locale, numericality: { only_integer: { message: '%{value} is not a number' } }, allow_blank: true
  validates :undergrad_enrollment, numericality: { message: '%{value} is not a number' }, allow_blank: true
  validates :retention_all_students_ba, numericality: { message: '%{value} is not a number' }, allow_blank: true
  validates :retention_all_students_otb, numericality: { message: '%{value} is not a number' }, allow_blank: true
  validates :graduation_rate_all_students, numericality: { message: '%{value} is not a number' }, allow_blank: true
  validates :salary_all_students, numericality: { message: '%{value} is not a number' }, allow_blank: true
  validates :repayment_rate_all_students, numericality: { message: '%{value} is not a number' }, allow_blank: true
  validates :avg_stu_loan_debt, numericality: { message: '%{value} is not a number' }, allow_blank: true
  validates :c150_4_pooled_supp, numericality: { message: '%{value} is not a number' }, allow_blank: true
  validates :c150_l4_pooled_supp, numericality: { message: '%{value} is not a number' }, allow_blank: true

  before_save :set_derived_fields

  USE_COLUMNS = [
    :insturl, :pred_degree_awarded, :locale, :undergrad_enrollment,
    :retention_all_students_ba, :retention_all_students_otb,
    :graduation_rate_all_students, :transfer_out_rate_all_students,
    :salary_all_students, :repayment_rate_all_students, :avg_stu_loan_debt
  ]

  override_setters :cross, :ope, :ope6, :institution, :insturl,
    :pred_degree_awarded, :locale, :undergrad_enrollment, 
    :retention_all_students_ba, :retention_all_students_otb,
    :graduation_rate_all_students, :transfer_out_rate_all_students, 
    :salary_all_students, :repayment_rate_all_students, :avg_stu_loan_debt,
    :c150_4_pooled_supp, :c150_l4_pooled_supp

  #############################################################################
  ## to_graduation_rate_all_students
  ## Selects the proper graduation data data based on a field precedence.
  #############################################################################
  def to_graduation_rate_all_students
    c150_4_pooled_supp.present? ? c150_4_pooled_supp : 
      c150_l4_pooled_supp.present? ? c150_l4_pooled_supp : nil
  end

  #############################################################################
  ## set_derived_fields=
  ## Computes the values of derived fields just prior to saving. Note that 
  ## any fields here cannot be part of validations.
  #############################################################################
  def set_derived_fields
    self.graduation_rate_all_students = to_graduation_rate_all_students
  end
end

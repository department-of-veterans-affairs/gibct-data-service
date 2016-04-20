class Complaint < ActiveRecord::Base
  include Standardizable

  STATUSES = %w(active closed pending reserved)
  CLOSED_REASONS = [
      "resolved", "invalid", "information only", "no response",
      "unresolved"
  ]
  
  FAC_CODE_TERMS = { 
    cfc: ".*", cfbfc: "financial", cqbfc: "quality", crbfc: "refund", 
    cmbfc: "recruit", cabfc: "accreditation", cdrbfc: "degree", 
    cslbfc: "loans", cgbfc: "grade", cctbfc: "transfer", cjbfc: "job", 
    ctbfc: "transcript", cobfc: "other"
  }

  FAC_CODE_SUMS = {
    complaints_facility_code: :cfc, 
    complaints_financial_by_fac_code: :cfbfc, 
    complaints_quality_by_fac_code: :cqbfc, 
    complaints_refund_by_fac_code: :crbfc, 
    complaints_marketing_by_fac_code: :cmbfc, 
    complaints_accreditation_by_fac_code: :cabfc, 
    complaints_degree_requirements_by_fac_code: :cdrbfc, 
    complaints_student_loans_by_fac_code: :cslbfc, 
    complaints_grades_by_fac_code: :cgbfc, 
    complaints_credit_transfer_by_fac_code: :cctbfc, 
    complaints_job_by_fac_code: :cjbfc, 
    complaints_transcript_by_fac_code: :ctbfc, 
    complaints_other_by_fac_code: :cobfc
  }

  OPE6_SUMS = {
    complaints_main_campus_roll_up: :cfc, 
    complaints_financial_by_ope_id_do_not_sum: :cfbfc, 
    complaints_quality_by_ope_id_do_not_sum: :cqbfc, 
    complaints_refund_by_ope_id_do_not_sum: :crbfc, 
    complaints_marketing_by_ope_id_do_not_sum: :cmbfc, 
    complaints_accreditation_by_ope_id_do_not_sum: :cabfc, 
    complaints_degree_requirements_by_ope_id_do_not_sum: :cdrbfc, 
    complaints_student_loans_by_ope_id_do_not_sum: :cslbfc, 
    complaints_grades_by_ope_id_do_not_sum: :cgbfc, 
    complaints_credit_transfer_by_ope_id_do_not_sum: :cctbfc, 
    complaints_jobs_by_ope_id_do_not_sum: :cjbfc, 
    complaints_transcript_by_ope_id_do_not_sum: :ctbfc, 
    complaints_other_by_ope_id_do_not_sum: :cobfc
  }

  USE_COLUMNS = FAC_CODE_SUMS.keys + OPE6_SUMS.keys

  validates :status,  inclusion: { in: STATUSES }
  validates :closed_reason, inclusion: { in: CLOSED_REASONS }, allow_blank: true

  USE_COLUMNS.each { |c| validates c, numericality: true }
  FAC_CODE_TERMS.keys.each { |c| validates c, numericality: true }

  before_save :set_derived_fields

  override_setters :facility_code, :ope, :ope6, :institution,
    :status, :closed_reason, :issue, :cfc, :cfbfc, :cqbfc, 
    :crbfc, :cmbfc, :cabfc, :cdrbfc, :cslbfc, :cgbfc, :cctbfc, 
    :cjbfc, :ctbfc, :cobfc, :complaints_facility_code, 
    :complaints_financial_by_fac_code, :complaints_quality_by_fac_code, 
    :complaints_refund_by_fac_code, :complaints_marketing_by_fac_code, 
    :complaints_accreditation_by_fac_code, 
    :complaints_degree_requirements_by_fac_code, 
    :complaints_student_loans_by_fac_code, :complaints_grades_by_fac_code, 
    :complaints_credit_transfer_by_fac_code, :complaints_job_by_fac_code, 
    :complaints_transcript_by_fac_code, :complaints_other_by_fac_code,
    :complaints_main_campus_roll_up, 
    :complaints_financial_by_ope_id_do_not_sum, 
    :complaints_quality_by_ope_id_do_not_sum, 
    :complaints_refund_by_ope_id_do_not_sum, 
    :complaints_marketing_by_ope_id_do_not_sum, 
    :complaints_accreditation_by_ope_id_do_not_sum, 
    :complaints_degree_requirements_by_ope_id_do_not_sum, 
    :complaints_student_loans_by_ope_id_do_not_sum, 
    :complaints_grades_by_ope_id_do_not_sum, 
    :complaints_credit_transfer_by_ope_id_do_not_sum, 
    :complaints_jobs_by_ope_id_do_not_sum, 
    :complaints_transcript_by_ope_id_do_not_sum, 
    :complaints_other_by_ope_id_do_not_sum

  #############################################################################
  ## ok_to_sum?
  ## True if the complaint record is a valid, closed complaint.
  #############################################################################
  def ok_to_sum?
    status == "closed" && closed_reason != "invalid"
  end

  #############################################################################
  ## set_derived_fields=
  ## Computes the values of derived fields just prior to saving. Note that 
  ## any fields here cannot be part of validations.
  #############################################################################
  def set_derived_fields
    set_fac_code_terms if ok_to_sum?

    true
  end

  #############################################################################
  ## set_fac_code_terms
  ## Adds 1 to the current count of complaints by facility code.
  #############################################################################
  def set_fac_code_terms
    FAC_CODE_TERMS.each_pair do |c, v|
      self[c] = (issue =~ Regexp.new(v, true)).nil? ? 0 : 1
    end
  end  

  #############################################################################
  ## update_sums_by_fac
  ## Sums recurring complaints by facility_code.
  #############################################################################
  def self.update_sums_by_fac
    fac_code_terms = FAC_CODE_TERMS.keys
    fac_code_sums = FAC_CODE_SUMS.keys

    select_strings = fac_code_terms.each_with_index.map do |term, i|
      "sum(#{term}) as #{fac_code_sums[i]}"      
    end

    results = Complaint.select(:facility_code)
      .select(select_strings.join(", "))
      .where.not(facility_code: nil).group(:facility_code)

    Complaint.transaction do
      results.each do |result|
        attributes = fac_code_sums.inject({}) { |a, t| a[t] = result[t]; a }
        Complaint.where(facility_code: result.facility_code)
          .update_all(attributes)
      end
    end
  end

  #############################################################################
  ## update_sums_by_fac
  ## Sums recurring complaints by facility_code.
  #############################################################################
  def self.update_sums_by_ope6
    fac_code_terms = FAC_CODE_TERMS.keys
    ope6_sums = OPE6_SUMS.keys

    select_strings = fac_code_terms.each_with_index.map do |term, i|
      "sum(#{term}) as #{ope6_sums[i]}"      
    end

    results = Complaint.select(:ope6)
      .select(select_strings.join(", "))
      .where.not(ope6: nil).group(:ope6)

    Complaint.transaction do
      results.each do |result|
        attributes = ope6_sums.inject({}) { |a, t| a[t] = result[t]; a }
        Complaint.where(ope6: result.ope6)
          .update_all(attributes)
      end
    end
  end
end

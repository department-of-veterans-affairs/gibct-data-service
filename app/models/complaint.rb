###############################################################################
## Complaint
## Complaint data appears in its CSV as list of individual student veteran 
## complaints keyed by an optional facility code. Therefore each institution
## can have more than one complaint. If a facility code is not present, then
## the complaint is ignored (although OPE ids are provided, they are not 
## reliable as it turns out). We therefore null out OPE ids while processing
## the complaint CSV.
##
## The complaints themselves fall into a number of categories as detailed in
## the class constant FAC_CODE_TERMS hash. The keys are attributes of the 
## complaint that are incremented by 1 if the corresponding value is found
## in the complaint issue attribute. By summing these complaint attributes
## accross a given facility_code, we obtain complaints for that campus,
## and by summing accross an OPE6 id, we arrive at the roll-up sum for the
## entire institution. Note that all sums are not normalized as an artifact
## of how the original GIBCT, and its hastily constructed replacement, was 
## designed.
##
## To accomplish this, when saving each instance of a complaint, we check the
## the method :ok_to_sum? when the record is being saved. If not, all complaint
## counts remain at 0, otherwise we run the method :set_fac_code_terms to
## set each complaint type to a 0 or a 1 based on a regular expression match of
## the issue attribute with complaint category keywords. Summing all the 
## complaints for a given facility_code is then done by the method 
## :update_sums_by_fac (called after uploading the complaint CSV). Rolling up
## complaints to the institution (OPE6 id) is done by the method 
## :update_sums_by_ope6 while the data_csv table is being built.
##
## Whether or not a complaint is counted, it must have (1) a facility_code,
## (2) be closed, and (3) not be invalid.
###############################################################################

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

  validate :inclusion_validator

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
  ## lowercase_inclusion_validator
  ## Case insensitive inclusion validator
  #############################################################################
  def lowercase_inclusion_validator(attribute, collection, blank_ok = true)
    return if (var = eval(attribute.to_s)).blank? && blank_ok

    if !collection.include?(var.try(:downcase))
      errors.add(attribute, "#{var} not in [#{collection.join(', ')}]")
    end
  end

  #############################################################################
  ## inclusion_validator
  ## Case insensitive inclusion validator
  #############################################################################
  def inclusion_validator
    lowercase_inclusion_validator(:status, STATUSES, false)
    lowercase_inclusion_validator(:closed_reason, CLOSED_REASONS)
  end

  #############################################################################
  ## ok_to_sum?
  ## True if the complaint record is a valid, closed complaint.
  #############################################################################
  def ok_to_sum?
    status.try(:downcase) == "closed" && closed_reason.try(:downcase) != "invalid"
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
      # self[c] = (issue =~ Regexp.new(v, true)).nil? ? 0 : 1
      self[c] = Complaint.match(v, issue) ? 1 : 0
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
  ## update_ope_from_crosswalk
  ## Updates the Complaints opes from the crosswalk, which are maintained and
  ## more reliable. Returns a list of unique ope6s.
  #############################################################################
  def self.update_ope_from_crosswalk
    Complaint.all.each do |c|
      if crosswalk = VaCrosswalk.find_by(facility_code: c.facility_code)
        c.ope = crosswalk.ope
        c.save
      end
    end
  end

  #############################################################################
  ## update_sums_by_ope6
  ## Sums recurring complaints by ope6. Updates with the latest opes and ope6s
  ## from the crosswalk, and then computes the sums by ope6. Should only be
  ## called by DataCsv.update_with_complaint
  #############################################################################
  def self.update_sums_by_ope6
    # Complaint CSV opes are not reliable!
    ope6s = Complaint.update_ope_from_crosswalk

    fac_code_terms = FAC_CODE_TERMS.keys
    ope6_sum_terms = OPE6_SUMS.keys

    select_strings = fac_code_terms.each_with_index.map do |term, i|
      "sum(#{term}) as #{ope6_sum_terms[i]}"      
    end

    results = Complaint.select(:ope6)
      .select(select_strings.join(", "))
      .where.not(ope6: nil).group(:ope6)

    DataCsv.transaction do
      results.each do |result|
        attributes = ope6_sum_terms.inject({}) { |a, t| a[t] = result[t]; a }
        DataCsv.where(ope6: result.ope6)
          .update_all(attributes)
      end
    end
  end
end

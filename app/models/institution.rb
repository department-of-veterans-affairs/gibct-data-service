# frozen_string_literal: true

class Institution < ActiveRecord::Base
  include CsvHelper

  EMPLOYER = 'OJT'

  LOCALE = {
    11 => 'city', 12 => 'city', 13 => 'city',
    21 => 'suburban', 22 => 'suburban', 23 => 'suburban',
    31 => 'town', 32 => 'town', 33 => 'town', 41 => 'rural',
    42 => 'rural', 43 => 'rural'
  }.freeze

  DEGREES = {
    0 => nil,
    'ncd' => 'Certificate',
    1 => 'Certificate',
    '2-year' => 2,
    2 => 2,
    3 => 4,
    4 => 4,
    '4-year' => 4
  }.freeze

  TYPES = ['OJT', 'PRIVATE', 'FOREIGN', 'CORRESPONDENCE', 'FLIGHT', 'FOR PROFIT', 'PUBLIC'].freeze

  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution' => { column: :institution, converter: InstitutionConverter },
    'city' => { column: :city, converter: UpcaseConverter },
    'state' => { column: :state, converter: StateConverter },
    'zip' => { column: :zip, converter: ZipConverter },
    'country' => { column: :country, converter: UpcaseConverter },
    'type' => { column: :institution_type_name, converter: UpcaseConverter },
    'approved' => { column: :approved, converter: BooleanConverter },
    'correspondence' => { column: :correspondence, converter: BooleanConverter },
    'flight' => { column: :flight, converter: BooleanConverter },
    'bah' => { column: :bah, converter: NumberConverter },
    'cross' => { column: :cross, converter: CrossConverter },
    'ope' => { column: :ope, converter: OpeConverter },
    'ope6' => { column: :ope6, converter: Ope6Converter },
    'school_system_name' => { column: :f1sysnam, converter: BaseConverter },
    'school_system_code' => { column: :f1syscod, converter: NumberConverter },
    'alias' => { column: :ialias, converter: BaseConverter },
    'insturl' => { column: :insturl, converter: BaseConverter },
    'vet_tuition_policy_url' => { column: :vet_tuition_policy_url, converter: BaseConverter },
    'pred_degree_awarded' => { column: :pred_degree_awarded, converter: NumberConverter },
    'locale' => { column: :locale, converter: NumberConverter },
    'gibill' => { column: :gibill, converter: NumberConverter },
    'undergrad_enrollment' => { column: :undergrad_enrollment, converter: NumberConverter },
    'yr' => { column: :yr, converter: BooleanConverter },
    'student_veteran' => { column: :student_veteran, converter: BooleanConverter },
    'student_veteran_link' => { column: :student_veteran_link, converter: BaseConverter },
    'poe' => { column: :poe, converter: BooleanConverter },
    'eight_keys' => { column: :eight_keys, converter: BooleanConverter },
    'dodmou' => { column: :dodmou, converter: BooleanConverter },
    'sec_702' => { column: :sec_702, converter: BooleanConverter },
    'vetsuccess_name' => { column: :vetsuccess_name, converter: BaseConverter },
    'vetsuccess_email' => { column: :vetsuccess_email, converter: BaseConverter },
    'credit_for_mil_training' => { column: :credit_for_mil_training, converter: BooleanConverter },
    'vet_poc' => { column: :vet_poc, converter: BooleanConverter },
    'student_vet_grp_ipeds' => { column: :student_vet_grp_ipeds, converter: BooleanConverter },
    'soc_member' => { column: :soc_member, converter: BooleanConverter },
    'va_highest_degree_offered' => { column: :va_highest_degree_offered, converter: BaseConverter },
    'retention_rate_veteran_ba' => { column: :retention_rate_veteran_ba, converter: NumberConverter },
    'retention_all_students_ba' => { column: :retention_all_students_ba, converter: NumberConverter },
    'retention_rate_veteran_otb' => { column: :retention_rate_veteran_otb, converter: NumberConverter },
    'retention_all_students_otb' => { column: :retention_all_students_otb, converter: NumberConverter },
    'persistance_rate_veteran_ba' => { column: :persistance_rate_veteran_ba, converter: NumberConverter },
    'persistance_rate_veteran_otb' => { column: :persistance_rate_veteran_otb, converter: NumberConverter },
    'graduation_rate_veteran' => { column: :graduation_rate_veteran, converter: NumberConverter },
    'graduation_rate_all_students' => { column: :graduation_rate_all_students, converter: NumberConverter },
    'transfer_out_rate_veteran' => { column: :transfer_out_rate_veteran, converter: NumberConverter },
    'transfer_out_rate_all_students' => { column: :transfer_out_rate_all_students, converter: NumberConverter },
    'salary_all_students' => { column: :salary_all_students, converter: NumberConverter },
    'repayment_rate_all_students' => { column: :repayment_rate_all_students, converter: NumberConverter },
    'avg_stu_loan_debt' => { column: :avg_stu_loan_debt, converter: NumberConverter },
    'calendar' => { column: :calendar, converter: BaseConverter },
    'tuition_in_state' => { column: :tuition_in_state, converter: NumberConverter },
    'tuition_out_of_state' => { column: :tuition_out_of_state, converter: NumberConverter },
    'books' => { column: :books, converter: NumberConverter },
    'online_all' => { column: :online_all, converter: BooleanConverter },
    'p911_tuition_fees' => { column: :p911_tuition_fees, converter: NumberConverter },
    'p911_recipients' => { column: :p911_recipients, converter: NumberConverter },
    'p911_yellow_ribbon' => { column: :p911_yellow_ribbon, converter: NumberConverter },
    'p911_yr_recipients' => { column: :p911_yr_recipients, converter: NumberConverter },
    'accredited' => { column: :accredited, converter: BooleanConverter },
    'accreditation_type' => { column: :accreditation_type, converter: BaseConverter },
    'accreditation_status' => { column: :accreditation_status, converter: BaseConverter },
    'caution_flag' => { column: :caution_flag, converter: BooleanConverter },
    'caution_flag_reason' => { column: :caution_flag_reason, converter: BaseConverter },
    'school_closing' => { column: :school_closing, converter: BooleanConverter },
    'school_closing_on' => { column: :school_closing_on, converter: DateConverter },
    'school_closing_message' => { column: :school_closing_message, converter: BaseConverter },
    'closure109' => { column: :closure109, converter: BooleanConverter },
    'complaints_facility_code' => { column: :complaints_facility_code, converter: NumberConverter },
    'complaints_financial_by_fac_code' => { column: :complaints_financial_by_fac_code, converter: NumberConverter },
    'complaints_quality_by_fac_code' => { column: :complaints_quality_by_fac_code, converter: NumberConverter },
    'complaints_refund_by_fac_code' => { column: :complaints_refund_by_fac_code, converter: NumberConverter },
    'complaints_marketing_by_fac_code' => { column: :complaints_marketing_by_fac_code, converter: NumberConverter },
    'complaints_accreditation_by_fac_code' => {
      column: :complaints_accreditation_by_fac_code, converter: NumberConverter
    },
    'complaints_degree_requirements_by_fac_code' => {
      column: :complaints_degree_requirements_by_fac_code, converter: NumberConverter
    },
    'complaints_student_loans_by_fac_code' => {
      column: :complaints_student_loans_by_fac_code, converter: NumberConverter
    },
    'complaints_grades_by_fac_code' => { column: :complaints_grades_by_fac_code, converter: NumberConverter },
    'complaints_credit_transfer_by_fac_code' => {
      column: :complaints_credit_transfer_by_fac_code, converter: NumberConverter
    },
    'complaints_job_by_fac_code' => { column: :complaints_job_by_fac_code, converter: NumberConverter },
    'complaints_transcript_by_fac_code' => { column: :complaints_transcript_by_fac_code, converter: NumberConverter },
    'complaints_other_by_fac_code' => { column: :complaints_other_by_fac_code, converter: NumberConverter },
    'complaints_main_campus_roll_up' => { column: :complaints_main_campus_roll_up, converter: NumberConverter },
    'complaints_financial_by_ope_id_do_not_sum' => {
      column: :complaints_financial_by_ope_id_do_not_sum, converter: NumberConverter
    },
    'complaints_quality_by_ope_id_do_not_sum' => {
      column: :complaints_quality_by_ope_id_do_not_sum, converter: NumberConverter
    },
    'complaints_refund_by_ope_id_do_not_sum' => {
      column: :complaints_refund_by_ope_id_do_not_sum, converter: NumberConverter
    },
    'complaints_marketing_by_ope_id_do_not_sum' => {
      column: :complaints_marketing_by_ope_id_do_not_sum, converter: NumberConverter
    },
    'complaints_accreditation_by_ope_id_do_not_sum' => {
      column: :complaints_accreditation_by_ope_id_do_not_sum, converter: NumberConverter
    },
    'complaints_degree_requirements_by_ope_id_do_not_sum' => {
      column: :complaints_degree_requirements_by_ope_id_do_not_sum, converter: NumberConverter
    },
    'complaints_student_loans_by_ope_id_do_not_sum' => {
      column: :complaints_student_loans_by_ope_id_do_not_sum, converter: NumberConverter
    },
    'complaints_grades_by_ope_id_do_not_sum' => {
      column: :complaints_grades_by_ope_id_do_not_sum, converter: NumberConverter
    },
    'complaints_credit_transfer_by_ope_id_do_not_sum' => {
      column: :complaints_credit_transfer_by_ope_id_do_not_sum, converter: NumberConverter
    },
    'complaints_jobs_by_ope_id_do_not_sum' => {
      column: :complaints_jobs_by_ope_id_do_not_sum, converter: NumberConverter
    },
    'complaints_transcript_by_ope_id_do_not_sum' => {
      column: :complaints_transcript_by_ope_id_do_not_sum, converter: NumberConverter
    },
    'complaints_other_by_ope_id_do_not_sum' => {
      column: :complaints_other_by_ope_id_do_not_sum, converter: NumberConverter
    }
  }.freeze

  validates :facility_code, uniqueness: true, presence: true
  validates :version, :institution, :country, presence: true
  validates :institution_type_name, inclusion: { in: TYPES }

  has_many :yellow_ribbon_programs, dependent: :destroy

  self.per_page = 10

  def scorecard_link
    return nil unless school? && cross.present?
    [
      "https://collegescorecard.ed.gov/school/?#{cross}",
      institution.downcase.parameterize
    ].join('-')
  end

  def website_link
    return nil if insturl.blank?
    return insturl if insturl.start_with? 'http'
    "http://#{insturl}"
  end

  def vet_website_link
    return nil if vet_tuition_policy_url.blank?
    return vet_tuition_policy_url if vet_tuition_policy_url.start_with? 'http'
    "http://#{vet_tuition_policy_url}"
  end

  def complaints
    prefix = 'complaints_'
    attributes.each_with_object({}) do |(k, v), complaints|
      complaints[k.gsub(prefix, '')] = v if k.starts_with?(prefix)
      complaints
    end
  end

  def facility_map
    InstitutionTree.build(self)
  end

  # Returns a short locale description
  #
  def locale_type
    LOCALE[locale]
  end

  # Returns the highest degree offered.
  #
  def highest_degree
    DEGREES[pred_degree_awarded] || DEGREES[va_highest_degree_offered.try(:downcase)]
  end

  def school?
    institution_type_name != 'OJT'
  end

  # Given a search term representing a partial school name, returns all
  # schools starting with the search term.
  #
  def self.autocomplete(search_term, limit = 6)
    Institution.select('id, facility_code as value, institution as label')
               .where('lower(institution) LIKE (?)', "#{search_term}%")
               .limit(limit)
  end

  # Finds exact-matching facility_code or partial-matching school and city names
  #
  scope :search, lambda { |search_term, include_address = false|
    return if search_term.blank?
    clause = [
      'facility_code = (:facility_code)',
      'lower(institution) LIKE (:search_term)',
      'lower(city) LIKE (:search_term)'
    ]

    if include_address
      3.times do |i|
        clause << "lower(address_#{i + 1}) LIKE (:search_term)"
      end
    end

    where(
      clause.join(' OR '),
      facility_code: search_term.upcase,
      search_term: "%#{search_term}%"
    )
  }

  scope :filter, lambda { |field, value|
    return if value.blank?
    raise ArgumentError, 'Field name is required' if field.blank?
    if field == :category
      case value
      when 'school'
        where.not(institution_type_name: EMPLOYER)
      when 'employer'
        where(institution_type_name: EMPLOYER)
      end
    else
      case value
      when 'true', 'yes'
        where(field => true)
      when 'false', 'no'
        where.not(field => true)
      else
        where(field => value)
      end
    end
  }

  scope :filter_count, lambda { |field|
    group(field).where.not(field => nil).order(field).count
  }

  scope :version, ->(n) { where(version: n) }
end

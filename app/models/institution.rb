# frozen_string_literal: true

class Institution < ImportableRecord
  EMPLOYER = 'OJT'

  DEFAULT_IHL_SECTION_103_MESSAGE = 'Contact the School Certifying Official (SCO) for requirements'

  IHL_FACILITY_CODE_PREFIXES = %w[11 12 13 21 22 23 31 32 33].freeze

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

  COMMON_REMOVAL_REGEXP = Regexp.new(
    (
    Settings.search.common_character_list.map { |char| Regexp.escape(char) } +
        Settings.search.common_word_list.map { |word| "\\b#{Regexp.escape(word)}\\b" }
  ).join('|'),
    'i'
  )

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
    },
    'complies_with_sec_103' => { column: :complies_with_sec_103, converter: BooleanConverter },
    'solely_requires_coe' => { column: :solely_requires_coe, converter: BooleanConverter },
    'requires_coe_and_criteria' => { column: :requires_coe_and_criteria, converter: BooleanConverter },
    'poo_status' => { column: :poo_status, converter: BaseConverter },
    'latitude' => { column: :latitude, converter: NumberConverter },
    'longitude' => { column: :longitude, converter: NumberConverter }
  }.freeze

  has_many :caution_flags, -> { distinct_flags }, inverse_of: :institution, dependent: :destroy
  has_many :institution_programs, -> { order(:description) }, inverse_of: :institution, dependent: :nullify
  has_many :versioned_school_certifying_officials, -> { order 'priority, last_name' }, inverse_of: :institution
  has_many :yellow_ribbon_programs, dependent: :destroy
  has_many :institution_category_ratings, dependent: :destroy
  belongs_to :version

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
    select('institutions.id, facility_code as value, institution as label')
      .where('institution LIKE (?)', "#{search_term.upcase}%")
      .limit(limit)
  end

  # This is used both on Weams imports and in the search scope
  # Idea is to have a processed version of the institution column available to compare with
  # the trigram % operator against the processed search term
  def self.institution_search_term(search_term)
    return {} if search_term.blank?

    processed_search_term = search_term.gsub(COMMON_REMOVAL_REGEXP, '')

    return { search_term: search_term.dup, excluded_only: true } if processed_search_term.blank?

    { search_term: processed_search_term.strip }
  end

  # Use regex to determine if search_term matches the format of word(s), state Abbreviation
  # i.e. Charleston, SC
  def self.city_state_search_term?(search_term)
    if search_term.present?
      /[a-zA-Z]+\,+ +[a-zA-Z][a-zA-Z]/.match(search_term) &&
        VetsJsonSchema::CONSTANTS['usaStates'].include?(search_term.upcase.scan(/[^, ]*$/).first.to_s)
    end
  end

  def self.state_search_term?(search_term)
    VetsJsonSchema::CONSTANTS['usaStates'].include?(search_term.upcase) if search_term.present?
  end

  # Escape postgresql regex special characters that are used within search terms that are not caught by sanitize_sql
  def self.postgres_regex_escape(search_term)
    return search_term if search_term.blank?

    escaped_term = search_term.clone
    %w[( ) + [ ] ].each { |ec| escaped_term = escaped_term.gsub(ec.to_s, "\\#{ec}") }
    escaped_term
  end

  # Depending on feature flags and search term determines where clause for search
  scope :search, lambda { |query|
    return if query.blank? || query[:name].blank?

    search_term = query[:name]
    include_address = query[:include_address] || false
    state_search = query[:state_search] || false

    clause = ['facility_code = :upper_search_term']

    processed = institution_search_term(search_term)
    processed_search_term = processed[:search_term]
    excluded_only = processed[:excluded_only]

    if excluded_only
      clause <<  'institution % :institution_search_term'
    else
      clause <<  'institution_search % :institution_search_term'
      clause <<  'institution_search LIKE UPPER(:institution_search_term)'
    end

    clause << 'UPPER(city) = :upper_search_term'
    clause << 'UPPER(ialias) LIKE :upper_contains_term'
    clause << 'zip = :search_term'
    clause << 'country LIKE :upper_contains_term' if state_search

    if include_address
      3.times do |i|
        clause << "lower(address_#{i + 1}) LIKE :lower_contains_term"
      end
    end

    where(sanitize_sql_for_conditions([clause.join(' OR '),
                                       upper_search_term: search_term.upcase,
                                       upper_contains_term: "%#{search_term.upcase}%",
                                       lower_contains_term: "%#{search_term.downcase}%",
                                       search_term: search_term.to_s,
                                       institution_search_term: "%#{processed_search_term}%"]))
  }

  # Orders institutions by
  # - if country contains the search term or not
  # - weighted sort
  # - institution name
  #
  # WEIGHTED SORT:
  # All values should be between 0.0 and 1.0
  # Exact matches should add 1.0 to weight and not have a modifier
  # Use or add modifiers that are set in Settings.search.weight_modifiers to tweak weights if needed
  #
  # The weight is a sum of the cases below
  # ialias^^: exact match, if contains the search term as a word
  # city: exact match
  # institution: exact match, if starts with search term, similarity
  # institution_search: similarity
  # gibill^^: institution's value divided by provided max gibill value
  #
  # ^^ = Has a Settings.search.weight_modifiers setting
  #
  # facility_code and zip are not included in order by because of their standard formats
  scope :search_order, lambda { |query, max_gibill = 0|
    return order('institution') if query.blank? || query[:name].blank?

    search_term = query[:name]
    state_search = query[:state_search] || false

    weighted_sort = ['CASE WHEN UPPER(ialias) = :upper_search_term THEN 1 ELSE 0 END',
                     "CASE WHEN REGEXP_MATCH(ialias, :regexp_exists_as_word, 'i') IS NOT NULL " \
                       'THEN 1 * :alias_modifier ELSE 0 END',
                     'CASE WHEN UPPER(city) = :upper_search_term THEN 1 ELSE 0 END',
                     'CASE WHEN UPPER(institution) = :upper_search_term THEN 1 ELSE 0 END',
                     'CASE WHEN UPPER(institution) LIKE :upper_starts_with_term THEN 1 ELSE 0 END',
                     'COALESCE(SIMILARITY(institution, :search_term), 0)']

    processed = institution_search_term(search_term)
    processed_search_term = processed[:search_term]
    excluded_only = processed[:excluded_only]

    weighted_sort << 'COALESCE(SIMILARITY(institution_search, :institution_search_term), 0)' if excluded_only.blank?
    weighted_sort << '((COALESCE(gibill, 0)/CAST(:max_gibill as FLOAT)) * :gibill_modifier)' if max_gibill.nonzero?

    order_by = ["#{weighted_sort.join(' + ')} DESC NULLS LAST", 'institution']

    # not included in weighted_sort as weight value would have to be at least 4.0 to affect order
    order_by.unshift('CASE WHEN UPPER(country) LIKE :upper_contains_term THEN 1 ELSE 0 END DESC') if state_search

    alias_modifier = Settings.search.weight_modifiers.alias
    gibill_modifier = Settings.search.weight_modifiers.gibill
    institution_search_term = "%#{processed_search_term}%"
    regexp_exists_as_word = "\\y#{postgres_regex_escape(search_term)}\\y"
    
    sanitized_order_by = Institution.sanitize_sql_for_conditions([order_by.join(','),
                                                                  search_term: search_term,
                                                                  upper_search_term: search_term.upcase,
                                                                  upper_starts_with_term: "#{search_term.upcase}%",
                                                                  upper_contains_term: "%#{search_term.upcase}%",
                                                                  alias_modifier: alias_modifier,
                                                                  gibill_modifier: gibill_modifier,
                                                                  max_gibill: max_gibill,
                                                                  institution_search_term: institution_search_term,
                                                                  regexp_exists_as_word: regexp_exists_as_word])

    order(Arel.sql(sanitized_order_by))
  }

  scope :city_state_search_order, lambda { |max_gibill = 0|
    order_by = %w[city institution]

    order_by << '(COALESCE(gibill, 0)/CAST(:max_gibill as FLOAT))' if max_gibill.nonzero?

    sanitized_order_by = Institution.sanitize_sql_for_conditions([order_by.join(','),
                                                                  max_gibill: max_gibill])

    order(Arel.sql(sanitized_order_by))
  }

  scope :filter_result, lambda { |field, value|
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

  scope :no_extentions, -> { where("campus_type != 'E' OR campus_type IS NULL") }

  scope :approved_institutions, lambda { |version|
    joins(:version).no_extentions.where(approved: true, version: version)
  }

  scope :non_vet_tec_institutions, lambda { |version|
    approved_institutions(version).where(vet_tec_provider: false)
  }
end

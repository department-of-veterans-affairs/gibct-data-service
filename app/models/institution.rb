# frozen_string_literal: true

class Institution < ImportableRecord
  EMPLOYER = Weam::OJT
  SCHOOLS = [Weam::CORRESPONDENCE, Weam::FLIGHT, Weam::FOR_PROFIT, Weam::FOREIGN, Weam::PRIVATE, Weam::PUBLIC].freeze

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

  MILE_METER_CONVERSION_RATE = 1609.34

  # If columns need to be added, add them at the end to preserve upload integrity to other processes.
  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'institution' => { column: :institution, converter: Converters::InstitutionConverter },
    'city' => { column: :city, converter: Converters::UpcaseConverter },
    'state' => { column: :state, converter: Converters::StateConverter },
    'zip' => { column: :zip, converter: Converters::ZipConverter },
    'country' => { column: :country, converter: Converters::UpcaseConverter },
    'type' => { column: :institution_type_name, converter: Converters::UpcaseConverter },
    'approved' => { column: :approved, converter: Converters::BooleanConverter },
    'correspondence' => { column: :correspondence, converter: Converters::BooleanConverter },
    'flight' => { column: :flight, converter: Converters::BooleanConverter },
    'bah' => { column: :bah, converter: Converters::NumberConverter },
    'cross' => { column: :cross, converter: Converters::CrossConverter },
    'ope' => { column: :ope, converter: Converters::OpeConverter },
    'ope6' => { column: :ope6, converter: Converters::Ope6Converter },
    'school_system_name' => { column: :f1sysnam, converter: Converters::BaseConverter },
    'school_system_code' => { column: :f1syscod, converter: Converters::NumberConverter },
    'alias' => { column: :ialias, converter: Converters::BaseConverter },
    'insturl' => { column: :insturl, converter: Converters::BaseConverter },
    'vet_tuition_policy_url' => { column: :vet_tuition_policy_url, converter: Converters::BaseConverter },
    'pred_degree_awarded' => { column: :pred_degree_awarded, converter: Converters::NumberConverter },
    'locale' => { column: :locale, converter: Converters::NumberConverter },
    'gibill' => { column: :gibill, converter: Converters::NumberConverter },
    'undergrad_enrollment' => { column: :undergrad_enrollment, converter: Converters::NumberConverter },
    'yr' => { column: :yr, converter: Converters::BooleanConverter },
    'student_veteran' => { column: :student_veteran, converter: Converters::BooleanConverter },
    'student_veteran_link' => { column: :student_veteran_link, converter: Converters::BaseConverter },
    'poe' => { column: :poe, converter: Converters::BooleanConverter },
    'eight_keys' => { column: :eight_keys, converter: Converters::BooleanConverter },
    'dodmou' => { column: :dodmou, converter: Converters::BooleanConverter },
    'sec_702' => { column: :sec_702, converter: Converters::BooleanConverter },
    'vetsuccess_name' => { column: :vetsuccess_name, converter: Converters::BaseConverter },
    'vetsuccess_email' => { column: :vetsuccess_email, converter: Converters::BaseConverter },
    'credit_for_mil_training' => { column: :credit_for_mil_training, converter: Converters::BooleanConverter },
    'vet_poc' => { column: :vet_poc, converter: Converters::BooleanConverter },
    'student_vet_grp_ipeds' => { column: :student_vet_grp_ipeds, converter: Converters::BooleanConverter },
    'soc_member' => { column: :soc_member, converter: Converters::BooleanConverter },
    'va_highest_degree_offered' => { column: :va_highest_degree_offered, converter: Converters::BaseConverter },
    'retention_rate_veteran_ba' => { column: :retention_rate_veteran_ba, converter: Converters::NumberConverter },
    'retention_all_students_ba' => { column: :retention_all_students_ba, converter: Converters::NumberConverter },
    'retention_rate_veteran_otb' => { column: :retention_rate_veteran_otb, converter: Converters::NumberConverter },
    'retention_all_students_otb' => { column: :retention_all_students_otb, converter: Converters::NumberConverter },
    'persistance_rate_veteran_ba' => { column: :persistance_rate_veteran_ba, converter: Converters::NumberConverter },
    'persistance_rate_veteran_otb' => { column: :persistance_rate_veteran_otb, converter: Converters::NumberConverter },
    'graduation_rate_veteran' => { column: :graduation_rate_veteran, converter: Converters::NumberConverter },
    'graduation_rate_all_students' => { column: :graduation_rate_all_students, converter: Converters::NumberConverter },
    'transfer_out_rate_veteran' => { column: :transfer_out_rate_veteran, converter: Converters::NumberConverter },
    'transfer_out_rate_all_students' => { column: :transfer_out_rate_all_students, converter: Converters::NumberConverter },
    'salary_all_students' => { column: :salary_all_students, converter: Converters::NumberConverter },
    'repayment_rate_all_students' => { column: :repayment_rate_all_students, converter: Converters::NumberConverter },
    'avg_stu_loan_debt' => { column: :avg_stu_loan_debt, converter: Converters::NumberConverter },
    'calendar' => { column: :calendar, converter: Converters::BaseConverter },
    'tuition_in_state' => { column: :tuition_in_state, converter: Converters::NumberConverter },
    'tuition_out_of_state' => { column: :tuition_out_of_state, converter: Converters::NumberConverter },
    'books' => { column: :books, converter: Converters::NumberConverter },
    'online_all' => { column: :online_all, converter: Converters::BooleanConverter },
    'p911_tuition_fees' => { column: :p911_tuition_fees, converter: Converters::NumberConverter },
    'p911_recipients' => { column: :p911_recipients, converter: Converters::NumberConverter },
    'p911_yellow_ribbon' => { column: :p911_yellow_ribbon, converter: Converters::NumberConverter },
    'p911_yr_recipients' => { column: :p911_yr_recipients, converter: Converters::NumberConverter },
    'accredited' => { column: :accredited, converter: Converters::BooleanConverter },
    'accreditation_type' => { column: :accreditation_type, converter: Converters::BaseConverter },
    'accreditation_status' => { column: :accreditation_status, converter: Converters::BaseConverter },
    'caution_flag' => { column: :caution_flag, converter: Converters::BooleanConverter },
    'caution_flag_reason' => { column: :caution_flag_reason, converter: Converters::BaseConverter },
    'school_closing' => { column: :school_closing, converter: Converters::BooleanConverter },
    'school_closing_on' => { column: :school_closing_on, converter: Converters::DateConverter },
    'school_closing_message' => { column: :school_closing_message, converter: Converters::BaseConverter },
    'complaints_facility_code' => { column: :complaints_facility_code, converter: Converters::NumberConverter },
    'complaints_financial_by_fac_code' => { column: :complaints_financial_by_fac_code, converter: Converters::NumberConverter },
    'complaints_quality_by_fac_code' => { column: :complaints_quality_by_fac_code, converter: Converters::NumberConverter },
    'complaints_refund_by_fac_code' => { column: :complaints_refund_by_fac_code, converter: Converters::NumberConverter },
    'complaints_marketing_by_fac_code' => { column: :complaints_marketing_by_fac_code, converter: Converters::NumberConverter },
    'complaints_accreditation_by_fac_code' => {
      column: :complaints_accreditation_by_fac_code, converter: Converters::NumberConverter
    },
    'complaints_degree_requirements_by_fac_code' => {
      column: :complaints_degree_requirements_by_fac_code, converter: Converters::NumberConverter
    },
    'complaints_student_loans_by_fac_code' => {
      column: :complaints_student_loans_by_fac_code, converter: Converters::NumberConverter
    },
    'complaints_grades_by_fac_code' => {
      column: :complaints_grades_by_fac_code, converter: Converters::NumberConverter
    },
    'complaints_credit_transfer_by_fac_code' => {
      column: :complaints_credit_transfer_by_fac_code, converter: Converters::NumberConverter
    },
    'complaints_job_by_fac_code' => {
      column: :complaints_job_by_fac_code, converter: Converters::NumberConverter
    },
    'complaints_transcript_by_fac_code' => {
      column: :complaints_transcript_by_fac_code, converter: Converters::NumberConverter
    },
    'complaints_other_by_fac_code' => {
      column: :complaints_other_by_fac_code, converter: Converters::NumberConverter
    },
    'complaints_main_campus_roll_up' => {
      column: :complaints_main_campus_roll_up, converter: Converters::NumberConverter
    },
    'complaints_financial_by_ope_id_do_not_sum' => {
      column: :complaints_financial_by_ope_id_do_not_sum, converter: Converters::NumberConverter
    },
    'complaints_quality_by_ope_id_do_not_sum' => {
      column: :complaints_quality_by_ope_id_do_not_sum, converter: Converters::NumberConverter
    },
    'complaints_refund_by_ope_id_do_not_sum' => {
      column: :complaints_refund_by_ope_id_do_not_sum, converter: Converters::NumberConverter
    },
    'complaints_marketing_by_ope_id_do_not_sum' => {
      column: :complaints_marketing_by_ope_id_do_not_sum, converter: Converters::NumberConverter
    },
    'complaints_accreditation_by_ope_id_do_not_sum' => {
      column: :complaints_accreditation_by_ope_id_do_not_sum, converter: Converters::NumberConverter
    },
    'complaints_degree_requirements_by_ope_id_do_not_sum' => {
      column: :complaints_degree_requirements_by_ope_id_do_not_sum, converter: Converters::NumberConverter
    },
    'complaints_student_loans_by_ope_id_do_not_sum' => {
      column: :complaints_student_loans_by_ope_id_do_not_sum, converter: Converters::NumberConverter
    },
    'complaints_grades_by_ope_id_do_not_sum' => {
      column: :complaints_grades_by_ope_id_do_not_sum, converter: Converters::NumberConverter
    },
    'complaints_credit_transfer_by_ope_id_do_not_sum' => {
      column: :complaints_credit_transfer_by_ope_id_do_not_sum, converter: Converters::NumberConverter
    },
    'complaints_jobs_by_ope_id_do_not_sum' => {
      column: :complaints_jobs_by_ope_id_do_not_sum, converter: Converters::NumberConverter
    },
    'complaints_transcript_by_ope_id_do_not_sum' => {
      column: :complaints_transcript_by_ope_id_do_not_sum, converter: Converters::NumberConverter
    },
    'complaints_other_by_ope_id_do_not_sum' => {
      column: :complaints_other_by_ope_id_do_not_sum, converter: Converters::NumberConverter
    },
    'complies_with_sec_103' => { column: :complies_with_sec_103, converter: Converters::BooleanConverter },
    'solely_requires_coe' => { column: :solely_requires_coe, converter: Converters::BooleanConverter },
    'requires_coe_and_criteria' => { column: :requires_coe_and_criteria, converter: Converters::BooleanConverter },
    'poo_status' => { column: :poo_status, converter: Converters::BaseConverter },
    'latitude' => { column: :latitude, converter: Converters::NumberConverter },
    'longitude' => { column: :longitude, converter: Converters::NumberConverter },
    'employer_provider' => { column: :employer_provider, converter: Converters::BooleanConverter },
    'school_provider' => { column: :school_provider, converter: Converters::BooleanConverter },
    'in_state_tuition_information' => { column: :in_state_tuition_information, converter: Converters::BaseConverter },
    'vrrap_provider' => { column: :vrrap, converter: Converters::BooleanConverter },
    'ownership_name' => { column: :ownership_name, converter: Converters::BaseConverter },

    # The following columns were not initially included in the CSV export and have been added at the end for
    # completeness. If more columns are added to the CSV export in the future, they should be added here.
    # The primary user (Brian Grubb) uses the export for an import to another process and order matters.
    'version' => { column: :version, converter: Converters::NumberConverter },
    'approval_status' => { column: :approval_status, converter: Converters::BaseConverter },
    'stem_offered' => { column: :stem_offered, converter: Converters::BooleanConverter },
    'priority_enrollment' => { column: :priority_enrollment, converter: Converters::BooleanConverter },
    'online_only' => { column: :online_only, converter: Converters::BooleanConverter },
    'independent_study' => { column: :independent_study, converter: Converters::BooleanConverter },
    'distance_learning' => { column: :distance_learning, converter: Converters::BooleanConverter },
    'address_1' => { column: :address_1, converter: Converters::BaseConverter },
    'address_2' => { column: :address_2, converter: Converters::BaseConverter },
    'address_3' => { column: :address_3, converter: Converters::BaseConverter },
    'physical_address_1' => { column: :physical_address_1, converter: Converters::BaseConverter },
    'physical_address_2' => { column: :physical_address_2, converter: Converters::BaseConverter },
    'physical_address_3' => { column: :physical_address_3, converter: Converters::BaseConverter },
    'physical_city' => { column: :physical_city, converter: Converters::BaseConverter },
    'physical_state' => { column: :physical_state, converter: Converters::BaseConverter },
    'physical_zip' => { column: :physical_zip, converter: Converters::BaseConverter },
    'physical_country' => { column: :physical_country, converter: Converters::BaseConverter },
    'dod_bah' => { column: :dod_bah, converter: Converters::NumberConverter },
    'vet_tec_provider' => { column: :vet_tec_provider, converter: Converters::BooleanConverter },
    'closure109' => { column: :closure109, converter: Converters::BooleanConverter },
    'preferred_provider' => { column: :preferred_provider, converter: Converters::BooleanConverter },
    'stem_indicator' => { column: :stem_indicator, converter: Converters::BooleanConverter },
    'campus_type' => { column: :campus_type, converter: Converters::BaseConverter },
    'parent_facility_code_id' => { column: :parent_facility_code_id, converter: Converters::BaseConverter },
    'version_id' => { column: :version_id, converter: Converters::NumberConverter },
    'hbcu' => { column: :hbcu, converter: Converters::NumberConverter },
    'hcm2' => { column: :hcm2, converter: Converters::NumberConverter },
    'menonly' => { column: :menonly, converter: Converters::NumberConverter },
    'pctfloan' => { column: :pctfloan, converter: Converters::NumberConverter },
    'relaffil' => { column: :relaffil, converter: Converters::NumberConverter },
    'womenonly' => { column: :womenonly, converter: Converters::NumberConverter },
    'institution_search' => { column: :institution_search, converter: Converters::BaseConverter },
    'rating_count' => { column: :rating_count, converter: Converters::NumberConverter },
    'rating_average' => { column: :rating_average, converter: Converters::NumberConverter },
    'section_103_message' => { column: :section_103_message, converter: Converters::BaseConverter },
    'bad_address' => { column: :bad_address, converter: Converters::BooleanConverter },
    'high_school' => { column: :high_school, converter: Converters::BooleanConverter },
    'chief_officer' => { column: :chief_officer, converter: Converters::BaseConverter },
    'hsi' => { column: :hsi, converter: Converters::NumberConverter },
    'nanti' => { column: :nanti, converter: Converters::NumberConverter },
    'annhi' => { column: :annhi, converter: Converters::NumberConverter },
    'aanapii' => { column: :aanapii, converter: Converters::NumberConverter },
    'pbi' => { column: :pbi, converter: Converters::NumberConverter },
    'tribal' => { column: :tribal, converter: Converters::NumberConverter },
    'ungeocodable' => { column: :ungeocodable, converter: Converters::BooleanConverter }
  }.freeze

  attribute :distance

  has_many :caution_flags, -> { distinct_flags }, inverse_of: :institution, dependent: :destroy
  has_many :institution_programs, -> { order(:description) }, inverse_of: :institution, dependent: :nullify
  has_many :versioned_school_certifying_officials, -> { order 'priority, last_name' },
           inverse_of: :institution, dependent: nil

  has_many :yellow_ribbon_programs, dependent: :destroy
  has_one  :institution_rating, dependent: :destroy

  # for some reason, without the default it was letting it go thru with a nil value in Rails 6
  # Several rspec tests in Rails 7 were failing because it's now being enforced.
  belongs_to :version, default: -> { Version.current_production }

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

  def physical_address
    compact_address = [physical_address_1, physical_address_2, physical_address_3].compact.join(' ')
    return nil if compact_address.blank?

    compact_address
  end

  def address
    compact_address = [address_1, address_2, address_3].compact.join(' ')
    return nil if compact_address.blank?

    compact_address
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
      /[a-zA-Z]+,+ +[a-zA-Z][a-zA-Z]/.match(search_term) &&
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
    %w[( ) + [ ]].each { |ec| escaped_term = escaped_term.gsub(ec.to_s, "\\#{ec}") }
    escaped_term
  end

  def self.filter_high_school
    where(high_school: nil)
  end

  def self.ungeocodable_count
    ungeocodables.count
  end

  def self.ungeocodables
    version = Version.current_production
    approved_institutions(version).where(latitude: nil, longitude: nil, ungeocodable: true).order(:institution)
  end

  def self.unaccredited_count
    unaccrediteds.count
  end

  def self.unaccrediteds
    return [] unless Version.current_production

    version = Version.current_production

    str = <<-SQL
      SELECT institutions.institution, institutions.facility_code, institutions.ope, ars.agency_name, ars.accreditation_end_date
      FROM "institutions"
      INNER JOIN "versions" ON "versions"."id" = "institutions"."version_id"
      left join accreditation_institute_campuses aic on institutions.ope = aic.ope
      left outer join accreditation_records ars on aic.dapip_id = ars.dapip_id and ars.program_id = 1
      WHERE (campus_type != 'E' OR campus_type IS NULL)
      AND "institutions"."approved" = true
      AND "institutions"."version_id" = #{version.id}
      AND (institutions.accreditation_type is NULL
      and institutions.ope is not NULL)
      ORDER BY "institutions"."institution" ASC
    SQL

    ApplicationRecord.connection.execute(ApplicationRecord.sanitize_sql(str))
  end

  #
  # Scopes
  #

  scope :filter_count, lambda { |field|
    group(field).where.not(field => nil).order(field).count
  }

  scope :boolean_filter_count, lambda { |field, value = true|
    where(field => value).order(field).count
  }

  scope :no_extentions, -> { where("campus_type != 'E' OR campus_type IS NULL") }

  scope :approved_institutions, lambda { |version|
    joins(:version).no_extentions.where(approved: true, version: version)
  }

  scope :non_vet_tec_institutions, lambda { |version|
    approved_institutions(version).where(vet_tec_provider: false)
  }

  #
  # V0
  #

  # Depending on feature flags and search term determines where clause for search
  scope :search, lambda { |query|
    return if query.blank? || query[:name].blank?

    city_physical = production? ? 'city' : 'physical_city'
    zipcode_physical = production? ? 'zip' : 'physical_zip'
    country_physical = production? ? 'country' : 'physical_country'
    address_physical = production? ? 'address' : 'physical_address'
    search_term = query[:name]
    include_address = query[:include_address] || false

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
    clause << "UPPER(#{city_physical}) = :upper_search_term"
    clause << 'UPPER(ialias) LIKE :upper_contains_term'
    clause << "#{zipcode_physical} = :search_term"
    clause << "#{country_physical} LIKE :upper_contains_term"

    if include_address
      3.times do |i|
        clause << "lower(#{address_physical}_#{i + 1}) LIKE :lower_contains_term"
      end
    end

    where(sanitize_sql_for_conditions([clause.join(' OR '),
                                       { upper_search_term: search_term.upcase,
                                         upper_contains_term: "%#{search_term.upcase}%",
                                         lower_contains_term: "%#{search_term.downcase}%",
                                         search_term: search_term.to_s,
                                         institution_search_term: "%#{processed_search_term}%" }]))
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

    weighted_sort = [
      'CASE WHEN UPPER(ialias) = :upper_search_term THEN 1 ELSE 0 END',
      "CASE WHEN REGEXP_MATCH(ialias, :regexp_exists_as_word, 'i') IS NOT NULL " \
        'THEN 1 * :alias_modifier ELSE 0 END',
      'CASE WHEN UPPER(city) = :upper_search_term THEN 1 ELSE 0 END',
      'CASE WHEN UPPER(institution) = :upper_search_term THEN 1 ELSE 0 END',
      'CASE WHEN UPPER(institution) LIKE :upper_starts_with_term THEN 1 ELSE 0 END',
      'COALESCE(SIMILARITY(institution, :search_term), 0)'
    ]

    processed = institution_search_term(search_term)
    processed_search_term = processed[:search_term]
    excluded_only = processed[:excluded_only]

    weighted_sort << 'COALESCE(SIMILARITY(institution_search, :institution_search_term), 0)' if excluded_only.blank?
    weighted_sort << '((COALESCE(gibill, 0)/CAST(:max_gibill as FLOAT)) * :gibill_modifier)' if max_gibill.nonzero?

    order_by = [
      'CASE WHEN UPPER(country) LIKE :upper_contains_term THEN 1 ELSE 0 END DESC',
      "#{weighted_sort.join(' + ')} DESC NULLS LAST",
      'institution'
    ]

    alias_modifier = Settings.search.weight_modifiers.alias
    gibill_modifier = Settings.search.weight_modifiers.gibill
    institution_search_term = "%#{processed_search_term}%"
    regexp_exists_as_word = "\\y#{postgres_regex_escape(search_term)}\\y"

    sanitized_order_by = Institution.sanitize_sql_for_conditions([order_by.join(','),
                                                                  { search_term: search_term,
                                                                    upper_search_term: search_term.upcase,
                                                                    upper_starts_with_term: "#{search_term.upcase}%",
                                                                    upper_contains_term: "%#{search_term.upcase}%",
                                                                    alias_modifier: alias_modifier,
                                                                    gibill_modifier: gibill_modifier,
                                                                    max_gibill: max_gibill,
                                                                    institution_search_term: institution_search_term,
                                                                    regexp_exists_as_word: regexp_exists_as_word }])

    order(Arel.sql(sanitized_order_by))
  }

  scope :city_state_search_order, lambda { |max_gibill = 0|
    order_by = %w[city institution]

    order_by << '(COALESCE(gibill, 0)/CAST(:max_gibill as FLOAT))' if max_gibill.nonzero?

    sanitized_order_by = Institution.sanitize_sql_for_conditions([order_by.join(','),
                                                                  { max_gibill: max_gibill }])

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

  #
  # V1 search
  #

  # Depending on feature flags and search term determines where clause for search
  scope :search_v1, lambda { |query|
    return if query.blank? || query[:name].blank?

    search_term = query[:name]

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

    clause << 'UPPER(ialias) LIKE :upper_contains_term'

    where(sanitize_sql_for_conditions([clause.join(' OR '),
                                       { upper_search_term: search_term.upcase,
                                         upper_contains_term: "%#{search_term.upcase}%",
                                         institution_search_term: "%#{processed_search_term}%" }]))
  }

  # rubocop:disable Metrics/BlockLength
  scope :filter_result_v1, lambda { |query|
    filters = []
    # ['column name', 'query param name']
    [
      ['country'],
      ['name'],
      ['state'],
      # following are only present if including schools in results
      ['student_veteran'], # boolean
      %w[yr yellow_ribbon_scholarship], # boolean
      ['accredited'] # boolean
    ].filter { |filter_args| query.key?(filter_args.last) }
      .each do |filter_args|
      param_value = query[filter_args.last]
      clause = if %w[true yes].include?(param_value)
                 'IS true'
               elsif %w[false no].include?(param_value)
                 'IS false'
               else
                 "= '#{param_value}'"
               end

      # checks text field for a state and country else uses the state/country in filter
      # added step that makes sure it won't return results where the state field is null
      if filter_args.first == 'name'
        state_country_search = query['name'].split(',') if query['name'].present?
        if state_country_search
          # tests cover this, but SimpleCov doesn't pick it up
          # :nocov:
          if state_country_search[1].present?
            state = state_country_search[1].upcase.strip
            filters << "state = '#{state.gsub("'", "''")}'"
            filters << "physical_state = '#{state.gsub("'", "''")}'"
            filters << 'state IS NOT NULL'
            filters << 'physical_state IS NOT NULL'
          end
          if state_country_search[2].present?
            country = state_country_search[2].upcase.strip
            filters << "country = '#{country.gsub("'", "''")}'"
            filters << "physical_country = '#{country.gsub("'", "''")}'"
            filters << 'country IS NOT NULL'
            filters << 'physical_country IS NOT NULL'
          end
          # :nocov:
        end
      else
        filters << "#{filter_args.first} #{clause}"
        if filter_args.first == 'state' || filter_args.first == 'country'
          filters << "physical_#{filter_args.first} #{clause}"
          filters << "#{filter_args.first} IS NOT NULL"
          filters << "physical_#{filter_args.first} IS NOT NULL"
        end
      end
    end
    # default state is checked in frontend so these will only be present if their corresponding boxes are unchecked
    exclude_schools = query.key?(:exclude_schools)
    exclude_employers = query.key?(:exclude_employers)
    exclude_vettec = query.key?(:exclude_vettec)

    # frontend does not show these filters if excluding schools from results
    unless exclude_schools
      filters << 'institution_type_name NOT IN (:excludedTypes)' if query.key?(:excluded_school_types)
      filters << '(caution_flag IS NULL OR caution_flag IS FALSE)' if query.key?(:exclude_caution_flags)
      filters << set_special_mission_filters(query) if query.keys.find { |e| /special_mission/ =~ e }
    end

    # Cannot have preferred_provider checked when excluding vet_tec_providers
    preferred_provider = query[:preferred_provider] && !exclude_vettec || false

    if preferred_provider
      provider_filters = []
      # checked: vet tec, preferred
      provider_filters << '(vet_tec_provider IS TRUE AND preferred_provider IS TRUE)'
      # checked: schools
      provider_filters << 'school_provider IS TRUE' unless exclude_schools
      # checked: employers
      provider_filters << 'employer_provider IS TRUE' unless exclude_employers
      filters << '(' + provider_filters.join(' OR ') + ')'
    end

    filters << 'school_provider IS FALSE' if exclude_schools
    filters << 'employer_provider IS FALSE' if exclude_employers
    filters << 'vet_tec_provider IS FALSE' if exclude_vettec

    sanitized_clause = Institution.sanitize_sql_for_conditions([filters.join(' AND '),
                                                                { excludedTypes: query[:excluded_school_types] }])

    where(Arel.sql(sanitized_clause))
  }

  def self.set_special_mission_filters(query)
    filt = []
    query.each_key do |k|
      next unless k.include?('special_mission')

      v = query[k]
      next unless v.eql?('true')

      str = k.sub('special_mission_', '')
      filt << 'relaffil is not null' if str.eql?('relaffil')
      filt << str + ' = 1' unless str.eql?('relaffil')
    end

    '(' + filt.join(' OR ') + ')'
  end

  # rubocop:enable Metrics/BlockLength
  # Orders institutions by
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
  # institution: exact match, if starts with search term, similarity
  # institution_search: similarity
  # gibill^^: institution's value divided by provided max gibill value
  #
  # ^^ = Has a Settings.search.weight_modifiers setting
  #
  # facility_code and zip are not included in order by because of their standard formats
  scope :search_order_v1, lambda { |query, max_gibill = 0|
    return order('institution') if query.blank? || query[:name].blank?

    search_term = query[:name]

    weighted_sort = [
      'CASE WHEN UPPER(ialias) = :upper_search_term THEN 1 ELSE 0 END',
      "CASE WHEN REGEXP_MATCH(ialias, :regexp_exists_as_word, 'i') IS NOT NULL " \
      'THEN 1 * :alias_modifier ELSE 0 END',
      'CASE WHEN UPPER(institution) = :upper_search_term THEN 1 ELSE 0 END',
      'CASE WHEN UPPER(institution) LIKE :upper_starts_with_term THEN 1 ELSE 0 END',
      'COALESCE(SIMILARITY(institution, :search_term), 0)'
    ]

    processed = institution_search_term(search_term)
    processed_search_term = processed[:search_term]
    excluded_only = processed[:excluded_only]

    weighted_sort << 'COALESCE(SIMILARITY(institution_search, :institution_search_term), 0)' if excluded_only.blank?
    weighted_sort << '((COALESCE(gibill, 0)/CAST(:max_gibill as FLOAT)) * :gibill_modifier)' if max_gibill.nonzero?

    order_by = [
      "#{weighted_sort.join(' + ')} DESC NULLS LAST",
      'institution'
    ]

    alias_modifier = Settings.search.weight_modifiers.alias
    gibill_modifier = Settings.search.weight_modifiers.gibill
    institution_search_term = "%#{processed_search_term}%"
    regexp_exists_as_word = "\\y#{postgres_regex_escape(search_term)}\\y"

    sanitized_order_by = Institution.sanitize_sql_for_conditions([order_by.join(','),
                                                                  { search_term: search_term,
                                                                    upper_search_term: search_term.upcase,
                                                                    upper_starts_with_term: "#{search_term.upcase}%",
                                                                    alias_modifier: alias_modifier,
                                                                    gibill_modifier: gibill_modifier,
                                                                    max_gibill: max_gibill,
                                                                    institution_search_term: institution_search_term,
                                                                    regexp_exists_as_word: regexp_exists_as_word }])

    order(Arel.sql(sanitized_order_by))
  }

  #
  # V1 Location
  #

  scope :location_select, lambda { |query|
    return select if query.blank? || query[:latitude].blank? || query[:longitude].blank?

    latitude = query[:latitude]
    longitude = query[:longitude]
    # rubocop:disable Layout/LineLength
    distance_column = 'earth_distance(ll_to_earth(:latitude,:longitude), ll_to_earth(latitude, longitude))/:conversion_rate distance'
    # rubocop:enable Layout/LineLength

    clause = ['institutions.*', distance_column]

    select(sanitize_sql_for_conditions([clause.join(','),
                                        { table_name: table_name,
                                          latitude: latitude,
                                          longitude: longitude,
                                          conversion_rate: MILE_METER_CONVERSION_RATE }]))
  }

  scope :location_search, lambda { |query|
    return if query.blank? || query[:latitude].blank? || query[:longitude].blank?

    latitude = query[:latitude]
    longitude = query[:longitude]
    distance = query[:distance] || 50

    # rubocop:disable Layout/LineLength
    clause = 'earth_distance(ll_to_earth(:latitude,:longitude), ll_to_earth(latitude, longitude))/:conversion_rate <= :distance'
    # rubocop:enable Layout/LineLength

    where(sanitize_sql_for_conditions([clause,
                                       { latitude: latitude,
                                         longitude: longitude,
                                         conversion_rate: MILE_METER_CONVERSION_RATE,
                                         distance: distance }]))
  }

  scope :location_order, lambda {
    order('distance')
  }
end

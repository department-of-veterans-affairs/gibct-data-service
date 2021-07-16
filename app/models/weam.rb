# frozen_string_literal: true

# Weams CSV file format
# Skipped first lines before header: 0
# Blank line following header: 1
# Row Separator: '\r\n' when uploaded from VA
# Col Separator: normally ',' but can be '|'
# Quirks: protectorates are listed as states
# rubocop:disable Metrics/ClassLength
class Weam < ImportableRecord
  OJT = 'OJT'
  PRIVATE = 'PRIVATE'
  FOREIGN = 'FOREIGN'
  CORRESPONDENCE = 'CORRESPONDENCE'
  FLIGHT = 'FLIGHT'
  FOR_PROFIT = 'FOR PROFIT'
  PUBLIC = 'PUBLIC'

  REQUIRED_VET_TEC_LAW_CODE = 'educational institution is approved for vet tec only'

  LAW_CODES_BLOCKING_APPROVED_STATUS = [
    'educational institution is not approved',
    'educational institution is approved for chapter 31 only'
  ].freeze

  COLS_USED_IN_INSTITUTION = %i[
    facility_code institution city state zip
    address_1 address_2 address_3
    country accredited bah poe yr poo_status
    institution_type_name va_highest_degree_offered flight correspondence
    independent_study priority_enrollment
    physical_address_1 physical_address_2 physical_address_3
    physical_city physical_state physical_zip physical_country
    dod_bah online_only distance_learning approved preferred_provider stem_indicator
    campus_type parent_facility_code_id institution_search in_state_tuition_information
  ].freeze

  # Used by loadable and (TODO) will be used with added include: true|false when building data.csv
  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution_name' => { column: :institution, converter: InstitutionConverter },
    'address_1' => { column: :address_1, converter: BaseConverter },
    'address_2' => { column: :address_2, converter: BaseConverter },
    'address_3' => { column: :address_3, converter: BaseConverter },
    'institution_city' => { column: :city, converter: UpcaseConverter },
    'institution_state' => { column: :state, converter: StateConverter },
    'institution_zip_code' => { column: :zip, converter: ZipConverter },
    'institution_country' => { column: :country, converter: UpcaseConverter },
    'accredited' => { column: :accredited, converter: BooleanConverter },
    'current_academic_year_va_bah_rate' => { column: :bah, converter: NumberConverter },
    'principles_of_excellence' => { column: :poe, converter: BooleanConverter },
    'current_academic_year_yellow_ribbon' => { column: :yr, converter: BooleanConverter },
    'poo_status' => { column: :poo_status, converter: BaseConverter },
    'applicable_law_code' => { column: :applicable_law_code, converter: BaseConverter },
    'institution_of_higher_learning_indicator' => {
      column: :institution_of_higher_learning_indicator, converter: BooleanConverter
    },
    'ojt_indicator' => { column: :ojt_indicator, converter: BooleanConverter },
    'correspondence_indicator' => { column: :correspondence_indicator, converter: BooleanConverter },
    'flight_indicator' => { column: :flight_indicator, converter: BooleanConverter },
    'non_college_degree_indicator' => { column: :non_college_degree_indicator, converter: BooleanConverter },
    'ipeds' => { column: :cross, converter: CrossConverter },
    'ope' => { column: :ope, converter: OpeConverter },
    'independent_study' => { column: :independent_study, converter: BooleanConverter },
    'physical_address_1' => { column: :physical_address_1, converter: BaseConverter },
    'physical_address_2' => { column: :physical_address_2, converter: BaseConverter },
    'physical_address_3' => { column: :physical_address_3, converter: BaseConverter },
    'physical_institution_city' => { column: :physical_city, converter: UpcaseConverter },
    'physical_institution_state' => { column: :physical_state, converter: StateConverter },
    'physical_institution_zip_code' => { column: :physical_zip, converter: ZipConverter },
    'physical_institution_country' => { column: :physical_country, converter: UpcaseConverter },
    'current_academic_year_dod_bah_rate' => { column: :dod_bah, converter: NumberConverter },
    'online_only' => { column: :online_only, converter: BooleanConverter },
    'distance_learning' => { column: :distance_learning, converter: BooleanConverter },
    'priority_enrollment' => { column: :priority_enrollment, converter: BooleanConverter },
    'preferred_provider' => { column: :preferred_provider, converter: BooleanConverter },
    'stem_indicator' => { column: :stem_indicator, converter: BooleanConverter },
    'campus_indicator' => { column: :campus_type, converter: BaseConverter },
    'parent_facility_code' => { column: :parent_facility_code_id, converter: BaseConverter },
    'in_state_tuition_url' => { column: :in_state_tuition_information, converter: BaseConverter }
  }.freeze

  has_many :crosswalk_issue, dependent: :delete_all
  validates :facility_code, :institution, :country, presence: true
  validate :institution_type
  validates :bah, numericality: true, allow_blank: true
  has_one(:arf_gi_bill, foreign_key: 'facility_code', primary_key: :facility_code,
                        inverse_of: :weam, dependent: :delete)

  after_initialize :derive_dependent_columns

  def institution_type
    msg = 'Unable to determine institution type'
    errors.add(:institution_type, msg) unless [OJT, PRIVATE, FOREIGN, CORRESPONDENCE,
                                               FLIGHT, FOR_PROFIT, PUBLIC].include?(institution_type_name)
  end

  # Computes all fields that are dependent on other fields. Called in validation because
  # activerecord-import does not engage callbacks when saving
  def derive_dependent_columns
    self.institution_type_name = derive_type
    self.va_highest_degree_offered = highest_degree_offered
    self.flight = flight?
    self.correspondence = correspondence?
    self.approved = approved?
    self.ope6 = Ope6Converter.convert(ope)
    self.institution_search = Institution.institution_search_term(institution)[:search_term]
  end

  # Is this instance an OJT institution?
  def ojt?
    facility_code.try(:[], 1) == '0'
  end

  # Does this institution offer a AA or BA if an institution of higher
  # learning, or a certification if an OJT?
  def offer_degree?
    institution_of_higher_learning_indicator || non_college_degree_indicator
  end

  # Is this a correspondence school?
  def correspondence?
    correspondence_indicator && !ojt? && !offer_degree?
  end

  # Is this a flight school?
  def flight?
    !correspondence? && flight_indicator && !ojt? && !offer_degree?
  end

  # Is this a foreign school?
  def foreign?
    !correspondence? && !flight? && !country.nil? && !country.match?(/\A(us|usa)\z/i)
  end

  # Is this a public school?
  def public?
    !correspondence? && !flight? && !foreign? && facility_code.try(:[], 0) == '1'
  end

  # Is this a for profit school (e.g., Devry or Phoenix)?
  def for_profit?
    !correspondence? && !flight? && !foreign? && facility_code.try(:[], 0) == '2'
  end

  # Is this a private school, like Princeton?
  def private?
    !public? && !for_profit?
  end

  # Gets the highest degree offered by facility_code at the campus level.
  def highest_degree_offered
    degree = { '0' => nil, '1' => '4-year', '2' => '4-year', '3' => '4-year', '4' => '2-year' }
    fac_digit = facility_code.try(:[], 1) || '5'

    degree.keys.include?(fac_digit) ? degree[fac_digit] : 'NCD'
  end

  # Gets the type of institution (public, private, ... )
  def derive_type
    {
      'OJT' => ojt?, 'CORRESPONDENCE' => correspondence?, 'FLIGHT' => flight?,
      'FOREIGN' => foreign?, 'PUBLIC' => public?, 'FOR PROFIT' => for_profit?,
      'PRIVATE' => private?
    }.key(true)
  end

  # True if the school offers a degree, higher learning institution, ojt, flight or
  # correspondence school
  def flags_for_approved?
    institution_of_higher_learning_indicator || ojt_indicator || correspondence_indicator ||
      flight_indicator || non_college_degree_indicator
  end

  # To be approved, a school must be marked 'aprvd' in the poo-status, have
  # an approved applicable law code that is not restrictive of GI Bill
  # benefits, and be a higher learning institution, OJT, flight,
  # correspondence or an institution that is a degree-granting concern.
  #
  # If school is a vet tec provider, applicable law code is VET TEC ONLY,
  # and be a non college degree indicator
  def approved?
    return false if applicable_law_code.blank?

    return false unless poo_status_valid?

    return vet_tec_approved? if vet_tec?

    return false if invalid_law_code?

    flags_for_approved?
  end

  def address_values
    [address_1, address_2, address_3, city, state, zip].compact
  end

  def physical_address_values
    [physical_address_1, physical_address_2, physical_address_3, physical_city, physical_state, physical_zip].compact
  end

  def address_values_for_match
    [city, zip, address_1].compact
  end

  def physical_address_values_for_match
    [physical_city, physical_zip, physical_address_1].compact
  end

  def address
    compact_address = [address_1, address_2, address_3].compact.join(' ')
    return nil if compact_address.blank?

    compact_address
  end

  def physical_address
    compact_address = [physical_address_1, physical_address_2, physical_address_3].compact.join(' ')
    return nil if compact_address.blank?

    compact_address
  end

  # Return approved rows with physical_city and physical_state where
  #   - does not have an ipeds_hd or scorecard
  #   - has ipeds_hd row but either physical city, physical state, or institution name does not match
  #   - has scorecard row but either physical city, or physical state does not match
  scope :missing_lat_long_physical, lambda {
    sql = <<-SQL
      SELECT weams.*
			FROM weams
			LEFT OUTER JOIN ipeds_hds ON weams.cross = ipeds_hds.cross
			LEFT OUTER JOIN scorecards ON weams.cross = scorecards.cross
			WHERE
      (
        (ipeds_hds.cross IS NULL AND scorecards.cross IS NULL)
        OR (ipeds_hds.cross IS NOT NULL
          AND (
            UPPER(ipeds_hds.city) != UPPER(weams.physical_city)
            OR UPPER(ipeds_hds.state) != UPPER(weams.physical_state)
            OR UPPER(weams.institution) != UPPER(ipeds_hds.institution)
            OR ipeds_hds.latitude IS NULL
            OR ipeds_hds.longitud IS NULL
            OR ipeds_hds.latitude NOT BETWEEN -90 AND 90
            OR ipeds_hds.longitud NOT BETWEEN -180 AND 180
          ))
        OR (scorecards.cross IS NOT NULL
          AND (
            UPPER(scorecards.city) != UPPER(weams.physical_city)
            OR UPPER(scorecards.state) != UPPER(weams.physical_state)
            OR scorecards.latitude IS NULL
            OR scorecards.longitude IS NULL
            OR scorecards.latitude NOT BETWEEN -90 AND 90
            OR scorecards.longitude NOT BETWEEN -180 AND 180
          ))
      )
      AND weams.physical_city IS NOT NULL AND weams.physical_state IS NOT NULL
      AND weams.approved IS TRUE
    SQL

    find_by_sql(sql)
  }

  # Return approved rows without physical_city or physical_state where
  #   - has ipeds_hd row but either city, or state does not match
  #   - has scorecard row but either city, or state does not match
  scope :missing_lat_long_mailing, lambda {
    sql = <<-SQL
      SELECT weams.*
      FROM weams
      LEFT OUTER JOIN ipeds_hds ON weams.cross = ipeds_hds.cross
      LEFT OUTER JOIN scorecards ON weams.cross = scorecards.cross
      WHERE (
        (ipeds_hds.cross IS NOT NULL
          AND (
            UPPER(ipeds_hds.city) != UPPER(weams.city)
            OR UPPER(ipeds_hds.state) != UPPER(weams.state)
            OR UPPER(ipeds_hds.institution) != UPPER(weams.institution)
        ))
        OR (scorecards.cross IS NOT NULL
          AND (UPPER(scorecards.city) != UPPER(weams.city)
          OR UPPER(scorecards.state) != UPPER(weams.state)
        ))
      )
      AND weams.physical_state IS NULL and weams.physical_city IS NULL
      AND weams.approved IS TRUE
    SQL

    find_by_sql(sql)
  }

  scope :approved_institutions, -> { where(approved: true) }

  private

  def poo_status_valid?
    !poo_status.nil? && poo_status.match?(/aprvd/i)
  end

  def invalid_law_code?
    LAW_CODES_BLOCKING_APPROVED_STATUS.any? { |law_code| applicable_law_code.downcase.include? law_code }
  end

  def vet_tec?
    facility_code.try(:[], 1) == 'V' && non_college_degree_indicator
  end

  def vet_tec_approved?
    applicable_law_code.downcase.include? REQUIRED_VET_TEC_LAW_CODE
  end
end

# rubocop:enable Metrics/ClassLength

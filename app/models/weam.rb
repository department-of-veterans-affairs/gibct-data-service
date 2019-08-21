# frozen_string_literal: true

# Weams CSV file format
# Skipped first lines before header: 0
# Blank line following header: 1
# Row Separator: '\r\n' when uploaded from VA
# Col Separator: normally ',' but can be '|'
# Quirks: protectorates are listed as states
# rubocop:disable Metrics/ClassLength
class Weam < ActiveRecord::Base
  include CsvHelper

  REQUIRED_VET_TEC_LAW_CODE = 'Educational Institution is Approved For Vet Tec Only'

  LAW_CODES_BLOCKING_APPROVED_STATUS = [
    'educational institution is not approved',
    'educational institution is approved for chapter 31 only'
  ].freeze

  COLS_USED_IN_INSTITUTION = %i[
    facility_code institution city state zip
    address_1 address_2 address_3
    country accredited bah poe yr
    institution_type_name va_highest_degree_offered flight correspondence
    independent_study priority_enrollment
    physical_address_1 physical_address_2 physical_address_3
    physical_city physical_state physical_zip physical_country
    dod_bah online_only distance_learning approved preferred_provider stem_indicator
    campus_type parent_facility_code_id
  ].freeze

  # Used by loadable and (TODO) will be used with added include: true|false when building data.csv
  CSV_CONVERTER_INFO = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution name' => { column: :institution, converter: InstitutionConverter },
    'address 1' => { column: :address_1, converter: BaseConverter },
    'address 2' => { column: :address_2, converter: BaseConverter },
    'address 3' => { column: :address_3, converter: BaseConverter },
    'institution city' => { column: :city, converter: UpcaseConverter },
    'institution state' => { column: :state, converter: StateConverter },
    'institution zip code' => { column: :zip, converter: ZipConverter },
    'institution country' => { column: :country, converter: UpcaseConverter },
    'accredited' => { column: :accredited, converter: BooleanConverter },
    'current academic year va bah rate' => { column: :bah, converter: NumberConverter },
    'principles of excellence' => { column: :poe, converter: BooleanConverter },
    'current academic year yellow ribbon' => { column: :yr, converter: BooleanConverter },
    'poo status' => { column: :poo_status, converter: BaseConverter },
    'applicable law code' => { column: :applicable_law_code, converter: BaseConverter },
    'institution of higher learning indicator' => {
      column: :institution_of_higher_learning_indicator, converter: BooleanConverter
    },
    'ojt indicator' => { column: :ojt_indicator, converter: BooleanConverter },
    'correspondence indicator' => { column: :correspondence_indicator, converter: BooleanConverter },
    'flight indicator' => { column: :flight_indicator, converter: BooleanConverter },
    'non-college degree indicator' => { column: :non_college_degree_indicator, converter: BooleanConverter },
    'ipeds' => { column: :cross, converter: CrossConverter },
    'ope' => { column: :ope, converter: OpeConverter },
    'independent study' => { column: :independent_study, converter: BooleanConverter },
    'physical address 1' => { column: :physical_address_1, converter: BaseConverter },
    'physical address 2' => { column: :physical_address_2, converter: BaseConverter },
    'physical address 3' => { column: :physical_address_3, converter: BaseConverter },
    'physical institution city' => { column: :physical_city, converter: UpcaseConverter },
    'physical institution state' => { column: :physical_state, converter: StateConverter },
    'physical institution zip code' => { column: :physical_zip, converter: ZipConverter },
    'physical institution country' => { column: :physical_country, converter: UpcaseConverter },
    'current academic year dod bah rate' => { column: :dod_bah, converter: NumberConverter },
    'online only' => { column: :online_only, converter: BooleanConverter },
    'distance learning' => { column: :distance_learning, converter: BooleanConverter },
    'priority enrollment' => { column: :priority_enrollment, converter: BooleanConverter },
    'preferred provider' => { column: :preferred_provider, converter: BooleanConverter },
    'stem indicator' => { column: :stem_indicator, converter: BooleanConverter },
    'campus type' => { column: :campus_type, converter: BaseConverter },
    'parent facility code id' => { column: :parent_facility_code_id, converter: BaseConverter }
  }.freeze

  validates :facility_code, :institution, :institution_type_name, presence: true
  validates :bah, numericality: true, allow_blank: true

  after_initialize :derive_dependent_columns

  # Computes all fields that are dependent on other fields. Called in validation because
  # activerecord-import does not engage callbacks when saving
  def derive_dependent_columns
    self.institution_type_name = derive_type
    self.va_highest_degree_offered = highest_degree_offered
    self.flight = flight?
    self.correspondence = correspondence?
    self.approved = approved?
    self.ope6 = Ope6Converter.convert(ope)
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
    !correspondence? && !flight? && (country =~ Regexp.new('\A(us|usa)\z', 'i')).nil?
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

  private

  def poo_status_valid?
    poo_status =~ Regexp.new('aprvd', 'i')
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

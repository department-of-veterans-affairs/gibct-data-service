# frozen_string_literal: true

# Weams CSV file format
# Skipped first lines before header: 0
# Blank line following header: 1
# Row Separator: '\r\n' when uploaded from VA
# Col Separator: normally ',' but can be '|'
# Quirks: protectorates are listed as states
class Weam < ActiveRecord::Base
  include Loadable, Exportable

  ALC1 = 'educational institution is not approved'
  ALC2 = 'educational institution is approved for chapter 31 only'

  # Used by loadable and (TODO) will be used with added include: true|false when building data.csv
  MAP = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution name' => { column: :institution, converter: InstitutionConverter },
    'address 1' => { column: :address_1, converter: BaseConverter },
    'address 2' => { column: :address_2, converter: BaseConverter },
    'address 3' => { column: :address_3, converter: BaseConverter },
    'institution city' => { column: :city, converter: BaseConverter },
    'institution state' => { column: :state, converter: StateConverter },
    'institution zip code' => { column: :zip, converter: ZipConverter },
    'institution country' => { column: :country, converter: BaseConverter },
    'accredited' => { column: :accredited, converter: BooleanConverter },
    'current academic year bah rate' => { column: :bah, converter: BaseConverter },
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
    'ope' => { column: :ope, converter: OpeConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :institution, presence: true
  validates :bah, numericality: true, allow_blank: true

  before_validation :derive_dependent_columns

  # Computes all fields that are dependent on other fields. Called in validation because
  # activerecord-import does not engage callbacks when saving
  def derive_dependent_columns
    self.institution_type = derive_type
    self.va_highest_degree_offered = highest_degree_offered
    self.flight = flight?
    self.correspondence = correspondence?
    self.approved = approved?
    self.ope6 = Ope6Converter.convert(ope)

    true
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
      'ojt' => ojt?, 'correspondence' => correspondence?, 'flight' => flight?,
      'foreign' => foreign?, 'public' => public?, 'for profit' => for_profit?,
      'private' => private?
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
  def approved?
    return false unless poo_status =~ Regexp.new('aprvd', 'i')
    return false if applicable_law_code =~ Regexp.new("#{ALC1}|#{ALC2}", 'i')

    flags_for_approved?
  end
end

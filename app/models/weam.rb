# frozen_string_literal: true
class Weam < ActiveRecord::Base
  include Savable, Standardizable

  before_validation :compute_derived_fields

  ALC1 = 'educational institution is not approved'.freeze
  ALC2 = 'educational institution is approved for chapter 31 only'.freeze

  HEADER_MAP = {
    'facility code' => :facility_code,
    'institution name' => :name,
    'institution city' => :city,
    'institution state' => :state,
    'institution zip code' => :zip,
    'institution country' => :country,
    'accredited' => :accredited,
    'current academic year bah rate' => :bah,
    'principles of excellence' => :poe,
    'current academic year yellow ribbon' => :yr,
    'poo status' => :poo_status,
    'applicable law code' => :applicable_law_code,
    'institution of higher learning indicator' => :institution_of_higher_learning_indicator,
    'ojt indicator' => :ojt_indicator,
    'correspondence indicator' => :correspondence_indicator,
    'flight indicator' => :flight_indicator,
    'non-college degree indicator' => :non_college_degree_indicator
  }.freeze

  validates :facility_code, presence: true
  validates :facility_code, uniqueness: true, unless: :skip_uniqueness
  validates :name, presence: true
  validates :institution_type, presence: true
  validates :bah, numericality: true, allow_blank: true

  # computes all fields that are dependent on other fields
  def compute_derived_fields
    self.institution_type = weams_type
    self.va_highest_degree_offered = highest_degree_offered

    self.flight = flight?
    self.correspondence = correspondence?
    self.approved = approved?

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
    !flight? && country =~ Regexp.new('\A(us|usa)\z')
  end

  # Is this a public school?
  def public?
    !foreign? && facility_code.try(:[], 0) == '1'
  end

  # Is this a for profit school (e.g., Devry or Phoenix)?
  def for_profit?
    !foreign? && facility_code.try(:[], 0) == '2'
  end

  # Is this a private school, like Princeton?
  def private?
    !public? && !for_profit?
  end

  # Gets the highest degree offered by facility_code at the campus level.
  def highest_degree_offered
    degree = { '0' => nil, '1' => '4-year', '2' => '4-year', '3' => '4-year', '4' => '2-year' }
    fac_digit = facility_code[1] || '5'

    degree.keys.include?(fac_digit) ? degree[fac_digit] : 'NCD'
  end

  # Gets the type of institution (public, private, ... )
  def weams_type
    {
      'ojt' => ojt?, 'correspondence' => correspondence?, 'flight' => flight?,
      'foreign' => foreign?, 'public' => public?, 'for profit' => for_profit?,
      'private' => private?
    }.key(true)
  end

  # True if the school offers a degree, higher learning institution, ojt, flight or
  # correspondence school
  def flags_for_approved?
    institution_of_higher_learning_indicator || ojt_indicator ||
      correspondence_indicator || flight_indicator || non_college_degree_indicator
  end

  # To be approved, a school must be marked 'aprvd' in the poo-status, have
  # an approved applicable law code that is not restrictive of GI Bill
  # benefits, and be a higher learning institution, OJT, flight,
  # correspondence or an institution that is a degree-granting concern.
  def approved?
    return false unless poo_status =~ Regexp.new('aprvd')
    return false if applicable_law_code =~ Regexp.new("#{ALC1}|#{ALC2}")

    flags_for_approved?
  end
end

# frozen_string_literal: true
###############################################################################
## Weam
## Contains VA WEAMS data.
## NOTE that this file must be built first before any other other table is built
## into the DataCsv table.
##
## The intheritance_column must be changed to a non-existant coluumn because
## this table has a field named type, which causes rails to assume STI
## inheritance.
##
## ACL1 and ACL2 represent two phrases that would mark a school as not
## approved, and therefore not included as a GI BILL Eligible school.
##
## USE_COLUMNS hold those columns that get copied to the DataCsv table during
## the build process.
###############################################################################
class Weam < ActiveRecord::Base
  include Standardizable

  # GIBCT uses field called type, must kludge to prevent STI
  self.inheritance_column = 'inheritance_type'

  validates :facility_code, presence: true, uniqueness: true
  validates :institution, presence: true
  validates :bah, numericality: true, allow_blank: true

  # before_save :set_derived_fields
  before_validation :set_derived_fields

  ALC1 = 'educational institution is not approved'.freeze
  ALC2 = 'educational institution is approved for chapter 31 only'.freeze

  USE_COLUMNS = [
    :facility_code, :institution, :city, :state, :zip,
    :country, :accredited, :bah, :poe, :yr,
    :type, :va_highest_degree_offered, :flight, :correspondence
  ].freeze

  # Standard input from csvs
  override_setters :facility_code, :institution, :city, :state, :zip,
                   :country, :accredited, :bah, :poe, :yr,
                   :type, :va_highest_degree_offered, :flight, :correspondence,
                   :poo_status, :applicable_law_code,
                   :institution_of_higher_learning_indicator, :ojt_indicator,
                   :correspondence_indicator, :flight_indicator,
                   :non_college_degree_indicator, :approved

  #############################################################################
  ## set_derived_fields=
  ## Computes the values of derived fields just prior to saving. Note that
  ## any fields here cannot be part of validations.
  #############################################################################
  def set_derived_fields
    self.type = weams_type
    self.va_highest_degree_offered = highest_degree_offered

    self.flight = flight?
    self.correspondence = correspondence?
    self.approved = approved?

    true
  end

  #############################################################################
  ## ojt?
  ## Is this instance an OJT institution?
  #############################################################################
  def ojt?
    !facility_code.nil? && facility_code[1] == '0'
  end

  #############################################################################
  ## offer_degree?
  ## Does this institution offer a AA or BA if an institution of higher
  ## learning, or a certification if an OJT?
  #############################################################################
  def offer_degree?
    institution_of_higher_learning_indicator || non_college_degree_indicator
  end

  #############################################################################
  ## correspondence?
  ## Is this a correspondence school?
  #############################################################################
  def correspondence?
    correspondence_indicator && !ojt? && !offer_degree?
  end

  #############################################################################
  ## flight?
  ## Is this a flight school?
  #############################################################################
  def flight?
    !correspondence? && flight_indicator && !ojt? && !offer_degree?
  end

  #############################################################################
  ## foreign?
  ## Is this a foreign school?
  #############################################################################
  def foreign?
    # !flight? && country != "usa" && country != "us"
    !flight? && !Weam.match('^(usa|us)$', country)
  end

  #############################################################################
  ## public?
  ## Is this a public school?
  #############################################################################
  def public?
    !foreign? && !facility_code.nil? && facility_code[0] == '1'
  end

  #############################################################################
  ## for_profit?
  ## Is this a for profit school (e.g., Devry or Phoenix)?
  #############################################################################
  def for_profit?
    !foreign? && !facility_code.nil? && facility_code[0] == '2'
  end

  #############################################################################
  ## private?
  ## Is this a private school, like Princeton?
  #############################################################################
  def private?
    !public? && !for_profit?
  end

  #############################################################################
  ## va_highest_degree_offered
  ## Gets the highest degree offered by facility_code at the campus level.
  #############################################################################
  def highest_degree_offered
    degree = {
      '0' => nil, '1' => '4-year', '2' => '4-year', '3' => '4-year',
      '4' => '2-year'
    }

    !facility_code.nil? && degree.keys.include?(facility_code[1]) ? degree[facility_code[1]] : 'NCD'
  end

  #############################################################################
  ## weam_type
  ## Gets the type of institution (public, private, ... )
  #############################################################################
  def weams_type
    {
      'ojt' => ojt?, 'correspondence' => correspondence?, 'flight' => flight?,
      'foreign' => foreign?, 'public' => public?, 'for profit' => for_profit?,
      'private' => private?
    }.find { |_key, value| value }[0]
  end

  #############################################################################
  ## approved?
  ## To be approved, a school must be marked 'aprvd' in the poo-status, have
  ## an approved applicable law code that is not restrictive of GI Bill
  ## benefits, and be a higher learning institution, OJT, flight,
  ## correspondence or an institution that is a degree-granting concern.
  #############################################################################
  def approved?
    Weam.match('aprvd', poo_status) &&
      !Weam.match("^(#{ALC1}|#{ALC2})", applicable_law_code) &&
      (
        institution_of_higher_learning_indicator ||
        ojt_indicator ||
        correspondence_indicator ||
        flight_indicator ||
        non_college_degree_indicator
      )
  end
end

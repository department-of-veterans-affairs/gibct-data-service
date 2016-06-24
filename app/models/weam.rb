class Weam < ActiveRecord::Base
  include Standardizable

  # GIBCT uses field called type, must kludge to prevent STI
  self.inheritance_column = "inheritance_type"

  validates :facility_code, presence: true, uniqueness: true
  validates :institution, presence: true
  validates :bah, numericality: true, allow_blank: true

  # before_save :set_derived_fields
  before_validation :set_derived_fields

  ALC1 = 'educational institution is not approved'
  ALC2 = 'educational institution is approved for chapter 31 only'

  USE_COLUMNS = [
    :facility_code, :institution, :city, :state, :zip, 
    :country, :accredited, :bah, :poe, :yr, 
    :type, :va_highest_degree_offered, :flight, :correspondence
  ]

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
  #############################################################################
  def ojt?
    !facility_code.nil? && facility_code[1] == '0'                                 
  end

  #############################################################################
  ## offer_degree?
  #############################################################################
  def offer_degree?
    institution_of_higher_learning_indicator || non_college_degree_indicator
  end

  #############################################################################
  ## correspondence?
  #############################################################################
  def correspondence?
    correspondence_indicator && !ojt? && !offer_degree?
  end

  #############################################################################
  ## flight?
  #############################################################################
  def flight?
    !correspondence? && flight_indicator && !ojt? && !offer_degree?
  end

  #############################################################################
  ## foreign?
  #############################################################################
  def foreign?
    # !flight? && country != "usa" && country != "us"
    !flight? && !Weam.match("^(usa|us)$", country)
  end

  #############################################################################
  ## public?
  #############################################################################
  def public?
    !foreign? && !facility_code.nil? && facility_code[0] == "1"
  end

  #############################################################################
  ## for_profit?
  #############################################################################
  def for_profit?
    !foreign? && !facility_code.nil? && facility_code[0] == "2"
  end

  #############################################################################
  ## private?
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
    }.find { |key, value| value }[0]
  end

  #############################################################################
  ## approved?
  #############################################################################
  def approved?
    # poo_status == 'aprvd' &&
    #   applicable_law_code != ALC1 &&
    #   applicable_law_code != ALC2 &&
    #   (
    #     institution_of_higher_learning_indicator || 
    #     ojt_indicator ||
    #     correspondence_indicator ||
    #     flight_indicator ||
    #     non_college_degree_indicator
    #   )
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

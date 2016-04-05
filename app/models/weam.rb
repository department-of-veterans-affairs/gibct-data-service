class Weam < ActiveRecord::Base
  # GIBCT uses field called type, must kludge to prevent STI
  self.inheritance_column = "inheritance_type"

  validates :facility_code, presence: true, uniqueness: true
  validates :institution, presence: true

  before_save :set_derived_fields

  ALC1 = 'educational institution is not approved'
  ALC2 = 'educational institution is approved for chapter 31 only'

  USE_COLUMNS = [
    :facility_code, :institution, :city, :state, :zip, 
    :country, :accredited, :bah, :poe, :yr, 
    :type, :va_highest_degree_offered, :flight, :correspondence
  ]

  #############################################################################
  ## poe=
  ## Converts truthy/falsy strings to booleans
  #############################################################################
  def poe=(value)
    write_attribute(:poe, DS::Truth.truthy?(value))
  end

  #############################################################################
  ## yr=
  ## Converts truthy/falsy strings to booleans
  #############################################################################
  def yr=(value)
    write_attribute(:yr, DS::Truth.truthy?(value))
  end

  #############################################################################
  ## institution_of_higher_learning_indicator=
  ## Converts truthy/falsy strings to booleans
  #############################################################################
  def institution_of_higher_learning_indicator=(value)
    write_attribute(:institution_of_higher_learning_indicator, DS::Truth.truthy?(value))
  end

  #############################################################################
  ## ojt_indicator=
  ## Converts truthy/falsy strings to booleans
  #############################################################################
  def ojt_indicator=(value)
    write_attribute(:ojt_indicator, DS::Truth.truthy?(value))
  end

  #############################################################################
  ## correspondence_indicator=
  ## Converts truthy/falsy strings to booleans
  #############################################################################
  def correspondence_indicator=(value)
    write_attribute(:correspondence_indicator, DS::Truth.truthy?(value))
  end
  
  #############################################################################
  ## flight_indicator=
  ## Converts truthy/falsy strings to booleans
  #############################################################################
  def flight_indicator=(value)
    write_attribute(:flight_indicator, DS::Truth.truthy?(value))
  end
  
  #############################################################################
  ## non_college_degree_indicator=
  ## Converts truthy/falsy strings to booleans
  #############################################################################
  def non_college_degree_indicator=(value)
    write_attribute(:non_college_degree_indicator, DS::Truth.truthy?(value))
  end
  
  #############################################################################
  ## accredited=
  ## Converts truthy/falsy strings to booleans
  #############################################################################
  def accredited=(value)
    write_attribute(:accredited, DS::Truth.truthy?(value))
  end

  #############################################################################
  ## facility_code=
  ## Strips whitespace and sets value to upcase
  #############################################################################
  def facility_code=(value)
    write_attribute(:facility_code, value.try(:strip).try(:upcase))
  end

  #############################################################################
  ## state=
  ## Converts "state strings" to 2-character uppercase state abbreviations
  #############################################################################
  def state=(value)
    value = DS::State[value.try(:strip)]
    write_attribute(:state, value.try(:upcase))
  end

  #############################################################################
  ## poo_status=
  ## Strips whitespace and sets value to downcase
  #############################################################################
  def poo_status=(value)
    write_attribute(:poo_status, value.try(:strip).try(:downcase))
  end

  #############################################################################
  ## applicable_law_code=
  ## Strips whitespace and sets value to downcase
  #############################################################################
  def applicable_law_code=(value)
    write_attribute(:applicable_law_code, value.try(:strip).try(:downcase))
  end

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
    facility_code[1] == '0'                                 
  end

  #############################################################################
  ## correspondence?
  #############################################################################
  def correspondence?
    correspondence_indicator && !ojt?
  end

  #############################################################################
  ## flight?
  #############################################################################
  def flight?
    !correspondence? && flight_indicator
  end

  #############################################################################
  ## foreign?
  #############################################################################
  def foreign?
    !flight? && country != "USA" && country != "US"
  end

  #############################################################################
  ## public?
  #############################################################################
  def public?
    !foreign? && facility_code[0] == "1"
  end

  #############################################################################
  ## for_profit?
  #############################################################################
  def for_profit?
    !foreign? && facility_code[0] == "2"
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
    {
      '0' => ' ', '1' => '4-year', '2' => '4-year', '3' => '4-year',
      '4' => '2-year' 
    }[facility_code[1]] || 'NCD'
  end

  #############################################################################
  ## weam_type
  ## Gets the type of institution (public, private, ... )
  #############################################################################
  def weams_type
    { 
      'OJT' => ojt?, 'Correspondence' => correspondence?, 'Flight' => flight?,
      'Foreign' => foreign?, 'Public' => public?, 'For Profit' => for_profit?,
      'Private' => private?
    }.select { |key, value| value }.first[0]
  end

  #############################################################################
  ## approved?
  #############################################################################
  def approved?
    poo_status == 'aprvd' &&
      applicable_law_code != ALC1 &&
      applicable_law_code != ALC2 &&
      (
        institution_of_higher_learning_indicator || 
        ojt_indicator ||
        correspondence_indicator ||
        flight_indicator ||
        non_college_degree_indicator
      )
  end
end

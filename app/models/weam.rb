class Weam < ActiveRecord::Base
  validates :facility_code, presence: true, uniqueness: true
  validates :institution, presence: true
  validates :state, inclusion: { in: DS::State.get_names }, allow_blank: true

  ALC1 = 'educational institution is not approved'
  ALC2 = 'educational institution is approved for chapter 31 only'

  USE_COLUMNS = [
    :facility_code, :institution, :city, :state, :zip, :country, :accredited,
    :bah, :poe, :yr, :poo_status, :applicable_law_code, 
    :institution_of_higher_learning_indicator, :ojt_indicator,
    :correspondence_indicator, :flight_indicator, 
    :non_college_degree_indicator
  ]

  scope :approved, -> {
    where(
      "LOWER(weams.poo_status) = 'aprvd' AND "\
      "LOWER(weams.applicable_law_code) != '#{ALC1}' AND "\
      "LOWER(weams.applicable_law_code) != '#{ALC2}' AND ("\
        "LOWER(weams.institution_of_higher_learning_indicator) = 'yes' OR "\
        "LOWER(weams.ojt_indicator) = 'yes' OR "\
        "LOWER(weams.correspondence_indicator) = 'yes' OR "\
        "LOWER(weams.flight_indicator) = 'yes' OR "\
        "LOWER(weams.non_college_degree_indicator) = 'yes'"\
      ")"
    )
  }

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
    DS::Truth.truthy?(correspondence_indicator)
  end

  #############################################################################
  ## flight?
  #############################################################################
  def flight?
    !correspondence? && DS::Truth.truthy?(flight_indicator) 
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
  def va_highest_degree_offered
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
    poo_status.try(:downcase) == 'aprvd' &&
      applicable_law_code.try(:downcase) != ALC1 &&
      applicable_law_code.try(:downcase) != ALC2 &&
      (
        DS::Truth.truthy?(institution_of_higher_learning_indicator) || 
        DS::Truth.truthy?(ojt_indicator) ||
        DS::Truth.truthy?(correspondence_indicator) ||
        DS::Truth.truthy?(flight_indicator) ||
        DS::Truth.truthy?(non_college_degree_indicator)
      )
  end
end

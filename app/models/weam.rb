class Weam < ActiveRecord::Base
  validates :facility_code, presence: true, uniqueness: true
  validates :institution, presence: true
  validates :state, inclusion: { in: DS_ENUM::State.get_names }, allow_blank: true

  #############################################################################
  ## va_highest_degree_offered
  ## Gets the highest degree offered by facility_code at the campus level.
  #############################################################################
  def va_highest_degree_offered
    case facility_code[1]
    when "0"
      " "
    when "1", "2", "3"
      "4-year"
    when "4"
      "2-year"
    else
      "NCD"
    end
  end

  #############################################################################
  ## weam_type
  ## Gets the type of institution (public, private, ... )
  #############################################################################
  def weams_type
    if (country != "USA" && country != "US")
      "Foreign"
    elsif DS_ENUM::Truth.truthy?(flight_indicator)
      "Flight" 
    elsif DS_ENUM::Truth.truthy?(correspondence_indicator)
      "Correspondence" 
    elsif DS_ENUM::Truth.truthy?(ojt_indicator)
      "OJT" 
    else 
      ["Public", "For Profit", "Private"].fetch(facility_code[0].to_i - 1)
    end 
  end
end

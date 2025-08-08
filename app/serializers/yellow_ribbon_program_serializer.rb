# frozen_string_literal: true

class YellowRibbonProgramSerializer < ActiveModel::Serializer
  attributes :city,
             :contribution_amount,
             :correspondence,
             :country,
             :degree_level,
             :display_degree_levels,
             :distance_learning,
             :division_professional_school,
             :facility_code,
             :institution_id,
             :insturl,
             :latitude,
             :longitude,
             :number_of_students,
             :name_of_institution,
             :online_only,
             :state,
             :street_address,
             :student_veteran,
             :student_veteran_link,
             :ungeocodable,
             :year_of_yr_participation,
             :zip
  
  def display_degree_levels
    values = YellowRibbonDegreeLevelTranslation.find_by(raw_degree_level: object.degree_level.downcase)&.translations
    values.empty? ? ['Other'] : values
  end
end

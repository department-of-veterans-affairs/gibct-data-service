# frozen_string_literal: true

class YellowRibbonProgramSerializer < ActiveModel::Serializer
  attributes :city,
             :contribution_amount,
             :correspondence,
             :country,
             :degree_level,
             :distance_learning,
             :division_professional_school,
             :facility_code,
             :institution_id,
             :insturl,
             :latitude,
             :longitude,
             :number_of_students,
             :name_of_institution,
             :online_all,
             :online_only,
             :state,
             :street_address,
             :student_veteran,
             :student_vet_grp_ipeds,
             :student_veteran_link,
             :ungeocodable,
             :year_of_yr_participation,
             :zip
end

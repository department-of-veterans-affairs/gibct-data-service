# frozen_string_literal: true

class YellowRibbonProgramSerializer < ActiveModel::Serializer
  attributes :city,
             :contribution_amount,
             :country,
             :degree_level,
             :division_professional_school,
             :facility_code,
             :institution_id,
             :insturl,
             :number_of_students,
             :school_name_in_yr_database,
             :state,
             :street_address,
             :zip
end

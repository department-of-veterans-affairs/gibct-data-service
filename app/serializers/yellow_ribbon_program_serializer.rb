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
             :name_of_institution,
             :state,
             :street_address
end

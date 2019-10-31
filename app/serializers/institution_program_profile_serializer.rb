# frozen_string_literal: true

class InstitutionProgramProfileSerializer < ActiveModel::Serializer
  attributes :program_type,
             :description,
             :length_in_hours,
             :length_in_weeks,
             :provider_website,
             :phone_area_code,
             :phone_number,
             :school_locale,
             :tuition_amount,
             :va_bah,
             :dod_bah,
             :student_vet_group,
             :student_vet_group_website,
             :vet_success_name,
             :vet_success_email
end

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
             :provider_email_address
end

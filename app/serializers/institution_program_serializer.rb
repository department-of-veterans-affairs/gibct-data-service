# frozen_string_literal: true

class InstitutionProgramSerializer < ActiveModel::Serializer
  attributes :program_type,
             :description,
             :length_in_hours,
             :length_in_weeks,
             :facility_code,
             :tuition_amount,
             :institution_name,
             :city,
             :state,
             :country,
             :preferred_provider,
             :va_bah,
             :dod_bah,
             :school_closing,
             :school_closing_on,
             :caution_flag
end

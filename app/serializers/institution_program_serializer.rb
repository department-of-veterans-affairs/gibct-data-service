# frozen_string_literal: true

class InstitutionProgramSerializer < ActiveModel::Serializer
  attributes :program_type,
             :description,
             :facility_code,
             :institution_name,
             :city,
             :state,
             :country,
             :preferred_provider,
             :va_bah,
             :dod_bah,
             :school_closing,
             :school_closing_on,
             :caution_flags,
             :ojt_app_type
end

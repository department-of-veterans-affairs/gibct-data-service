# frozen_string_literal: true

module Lcpe
  class LacSerializer < ActiveModel::Serializer
    attribute :facility_code
    attribute :edu_lac_type_nm
    attribute :lac_nm
  end
end

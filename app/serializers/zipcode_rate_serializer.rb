# frozen_string_literal: true

class ZipcodeRateSerializer < ActiveModel::Serializer
  attribute :zip_code
  attribute :mha_code
  attribute :mha_name
  attribute :mha_rate
  attribute :mha_rate_grandfathered
  attribute :mha_dod_rate
end

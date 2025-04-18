# frozen_string_literal: true

class VersionedComplaintSerializer < ActiveModel::Serializer
  attribute :ope
  attribute :ope6
  attribute :closed
  attribute :facility_code
  attribute :categories
end

# frozen_string_literal: true

class ProgramSerializer < ActiveModel::Serializer
  attribute :program_type
  attribute :description
  attribute :full_time_undergraduate
  attribute :graduate
  attribute :full_time_modifier
  attribute :length
end

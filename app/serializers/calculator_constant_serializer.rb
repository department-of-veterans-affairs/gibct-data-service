# frozen_string_literal: true
class CalculatorConstantSerializer < ActiveModel::Serializer
  attributes :name, :value, :created_at
end

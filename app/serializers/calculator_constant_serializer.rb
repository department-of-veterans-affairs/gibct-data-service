# frozen_string_literal: true

class CalculatorConstantSerializer < ActiveModel::Serializer
  # Override model type
  type 'calculator_constants'

  attributes :name, :value

  def value
    object.float_value
  end
end

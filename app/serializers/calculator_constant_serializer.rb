# frozen_string_literal: true

class CalculatorConstantSerializer < ActiveModel::Serializer
  attributes :name, :value

  def value
    object.float_value
  end
end

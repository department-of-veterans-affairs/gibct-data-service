# frozen_string_literal: true

class CalculatorConstantsController < ApplicationController
  def index
    @calculator_constants = CalculatorConstant.all
  end

  def update
    updated_fields = []
    params.each do |key, value|
      next unless CalculatorConstant.exists?(name: key)

      constant_field = CalculatorConstant.where(name: key).first
      if constant_field.float_value != value.to_f
        constant_field.update(float_value: value)
        updated_fields.push(key)
      end
    end
    unless updated_fields.empty?
      flash[:success] = {
        updated_fields: updated_fields
      }
    end
    redirect_to action: :index
  end
end

# frozen_string_literal: true

class CalculatorConstantsController < ApplicationController
  def index
    @calculator_constants = CalculatorConstant.all
  end

  def update
    updated_fields = []
    params.each do |key, value|
      update_calculator_constant(key, value, updated_fields)
    end
    unless updated_fields.empty?
      flash[:success] = {
        updated_fields: updated_fields
      }
    end
    redirect_to action: :index
  end

  private

  def update_calculator_constant(name, value, updated_fields)
    if CalculatorConstant.exists?(name: name)
      constant_field = CalculatorConstant.where(name: name).first
      if constant_field.float_value != value.to_f
        constant_field.update(float_value: value)
        updated_fields.push(name)
      end
    end
  end
end

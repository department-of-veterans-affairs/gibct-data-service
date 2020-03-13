# frozen_string_literal: true

class CalculatorConstantsController < ApplicationController
  def index
    @calculator_constants = CalculatorConstant.all
  end

  def update
    updated_fields = []
    submitted_constants = params['calculator_constants'][0]
    update_calculator_constant(submitted_constants, updated_fields)
    unless updated_fields.empty?
      flash[:success] = {
        updated_fields: updated_fields
      }
    end
    redirect_to action: :index
  end

  private

  def update_calculator_constant(submitted_constants, updated_fields)
    constant_fields = CalculatorConstant.where(name: submitted_constants.keys)
    constant_fields.each do |constant|
      submitted_value = submitted_constants[constant.name]
      if submitted_value.to_f != constant.float_value
        constant.update(float_value: submitted_value)
        updated_fields.push(constant.name)
      end
    end
  end
end

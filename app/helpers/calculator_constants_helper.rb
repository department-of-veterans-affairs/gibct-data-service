# frozen_string_literal: true

module CalculatorConstantsHelper
  def display_value_for(constant)
    year_value?(constant) ? constant.float_value.to_i : format('%.2f', constant.float_value)
  end

  def step_value_for(constant)
    year_value?(constant) ? '1' : '0.01'
  end

  private

  def year_value?(constant)
    constant.name == 'FISCALYEAR'
  end
end

# frozen_string_literal: true

module CalculatorConstantsHelper
  def display_value_for(constant, attr)
    return unless %i[float_value previous_year].include?(attr)

    year_value?(constant) ? constant[attr].to_i : format('%.2f', constant[attr])
  end

  def step_value_for(constant)
    year_value?(constant) ? '1' : '0.01'
  end

  private

  def year_value?(constant)
    constant.name == 'FISCALYEAR'
  end
end

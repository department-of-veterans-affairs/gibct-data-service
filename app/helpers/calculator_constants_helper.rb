# frozen_string_literal: true

module CalculatorConstantsHelper
  def display_value_for(constant)
    return unless constant

    year_value?(constant) ? constant.float_value.to_i : decimalize(constant.float_value)
  end

  def decimalize(value)
    format('%.2f', value)
  end

  def step_value_for(constant)
    year_value?(constant) ? '1' : '0.01'
  end

  def constants_by_rate_adjustment(rate_adjustment:, constants:)
    constants.select { |c| c.rate_adjustment_id == rate_adjustment.id }.map(&:name)
  end

  def year_value?(constant)
    constant.name == 'FISCALYEAR'
  end
end

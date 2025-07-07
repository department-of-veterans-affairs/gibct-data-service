# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalculatorConstantsHelper, type: :helper do
  let(:nonyear_constant) { create(:calculator_constant, name: 'AVEGRADRATE') }
  let(:year_constant) { create(:calculator_constant, name: 'FISCALYEAR') }

  describe '#display_value_for' do
    it 'calls #decimalize on nonyear float values' do
      allow(helper).to receive(:decimalize).with(nonyear_constant.float_value)
      helper.display_value_for(nonyear_constant)
      expect(helper).to have_received(:decimalize).with(nonyear_constant.float_value)
    end

    it 'formats year values as integers' do
      expect(helper.display_value_for(year_constant)).to eq(year_constant.float_value.to_i)
    end
  end

  describe '#decimalize' do
    it 'formats float value within two decimal places and returns string' do
      expect(helper.decimalize(1)).to eq('1.00')
    end
  end

  describe '#step_value_for' do
    it 'returns 0.01 for nonyear constants' do
      expect(helper.step_value_for(nonyear_constant)).to eq('0.01')
    end

    it 'returns 1 for year constants' do
      expect(helper.step_value_for(year_constant)).to eq('1')
    end
  end

  describe '#constants_by_rate_adjustments' do
    let(:calculator_constant) { create(:calculator_constant, :associated_rate_adjustment) }
    let(:other_constants) { create_list(:calculator_constant, 2, :associated_rate_adjustment) }
    let(:all_constants) { CalculatorConstant.where(id: (other_constants << calculator_constant).map(&:id)) }

    it 'filters constants client-side by associated rate adjustment' do
      rate_adjustment = calculator_constant.rate_adjustment
      expect(helper.constants_by_rate_adjustment(rate_adjustment:, constants: all_constants))
        .to eq([calculator_constant.name])
    end
  end
end

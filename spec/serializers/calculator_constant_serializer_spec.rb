# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalculatorConstantSerializer, type: :serializer do
  subject { serialize(calculator_constant, serializer_class: described_class) }

  let(:calculator_constant) { create :calculator_constant_version }

  let(:data) { JSON.parse(subject)['data'] }
  let(:attributes) { data['attributes'] }

  it 'includes name' do
    expect(attributes['name']).to eq(calculator_constant.name)
  end

  it 'includes value' do
    expect(attributes['value']).to eq(calculator_constant.float_value)
  end

  it 'converts float_value to value' do
    expect(described_class.new(calculator_constant).value).to eq(calculator_constant.float_value)
  end

  it 'overwrites type' do
    expect(data['type']).to eq('calculator_constants')
  end
end

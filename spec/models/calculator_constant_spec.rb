# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe CalculatorConstant, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'instance methods' do
    it 'responds to value' do
      expect(build(:calculator_constant).value).to be_a(Float)
    end
  end

  describe 'when validating' do
    subject(:calculator_constant) { create :calculator_constant }

    it 'has a valid factory' do
      expect(calculator_constant).to be_valid
    end

    it 'requires uniqueness' do
      expect(calculator_constant.dup).not_to be_valid
    end

    it 'requires presence of name' do
      expect(build(:calculator_constant, name: nil)).not_to be_valid
    end
  end
end

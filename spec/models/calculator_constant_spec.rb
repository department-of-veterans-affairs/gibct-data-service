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

    it 'requires presence of float value' do
      expect(build(:calculator_constant, float_value: nil)).not_to be_valid
    end
  end

  describe '#set_rate_adjustment_if_exists' do
    subject(:calculator_constant) { create(:calculator_constant) }

    let(:rate_adjustment) { create :rate_adjustment }

    it 'returns false if description nil' do
      descriptionless = create(:calculator_constant, description: nil)
      expect(descriptionless.set_rate_adjustment_if_exists).to be false
    end

    it 'returns false if benefit type not included in description' do
      expect(calculator_constant.set_rate_adjustment_if_exists).to be false
    end

    it 'returns false if rate adjustment association already exists' do
      with_rate_adjustment = create(:calculator_constant, :associated_rate_adjustment)
      expect(with_rate_adjustment.set_rate_adjustment_if_exists).to be false
    end

    it 'returns false if benefit type not prefaced by Chapter or Ch.' do
      chapterless_description = "References #{rate_adjustment.benefit_type} benefit type"
      calculator_constant.update(description: chapterless_description)
      expect(calculator_constant.set_rate_adjustment_if_exists).to be false
    end

    it 'updates rate adjustment and returns true if match found' do
      matching_description = "References Ch. #{rate_adjustment.benefit_type} benefit type"
      calculator_constant.update(description: matching_description)
      expect(calculator_constant.set_rate_adjustment_if_exists).to be true
      expect(calculator_constant.rate_adjustment).to eq(rate_adjustment)
    end
  end
end

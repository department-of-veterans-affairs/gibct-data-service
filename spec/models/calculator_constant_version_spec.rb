# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe CalculatorConstantVersion, type: :model do
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:constant_version) { create(:calculator_constant_version) }

    it 'has a valid factory' do
      expect(constant_version).to be_valid
    end

    it 'requires uniqueness' do
      expect(constant_version.dup).not_to be_valid
    end

    it 'requires presence of name' do
      expect(build(:calculator_constant_version, name: nil)).not_to be_valid
    end

    it 'requires presence of float value' do
      expect(build(:calculator_constant_version, float_value: nil)).not_to be_valid
    end
  end
end

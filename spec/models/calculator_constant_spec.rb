# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CalculatorConstant, type: :model do
  describe 'instance methods' do
    it 'responds to value when string' do
      expect(build(:calculator_constant, :string).value).to be_a(String)
    end

    it 'responds to value when float' do
      expect(build(:calculator_constant, :float).value).to be_a(Float)
    end
  end

  describe 'when validating' do
    subject { create :calculator_constant }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires uniqueness' do
      expect(subject.dup).not_to be_valid
    end

    it 'requires presence of name' do
      expect(build(:calculator_constant, name: nil)).not_to be_valid
    end
  end
end

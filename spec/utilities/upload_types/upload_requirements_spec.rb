# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadRequirements do
  def validations(csv_class, requirement_class)
    csv_class.validators
             .find { |requirements| requirements.class == requirement_class }
  end

  def map_attributes(csv_class, requirement_class)
    validations(csv_class, requirement_class)
      .attributes
      .map { |column| csv_class::CSV_CONVERTER_INFO.select { |_k, v| v[:column] == column }.keys.join(', ') }
  end

  describe 'requirements_messages' do
    it 'returns validates numericality messages' do
      validations_of_str = 'current academic year va bah rate'
      message = { message: 'These columns can only contain numeric values: ', value: [validations_of_str] }

      messages = described_class.requirements_messages(Weam)
      expect(messages).to include(message)
    end

    it 'returns validates uniqueness messages' do
      validations_of_str = map_attributes(CalculatorConstant, ActiveRecord::Validations::UniquenessValidator)
      message = { message: 'These columns should contain unique values: ', value: validations_of_str }
      messages = described_class.requirements_messages(CalculatorConstant)
      expect(messages).to include(message)
    end

    it 'returns validates presence messages' do
      validations_of_str = 'name', 'value'
      message = { message: 'These columns must have a value: ', value: validations_of_str }
      messages = described_class.requirements_messages(CalculatorConstant)
      expect(messages).to include(message)
    end
  end

  it 'returns validates inclusion messages' do
    validations_of_str = validations(Complaint, ActiveModel::Validations::InclusionValidator)
    message = { message: 'status', value: validations_of_str.options[:in].map(&:to_s) }
    messages = described_class.validation_messages_inclusion(Complaint)
    expect(messages.first).to include(message)
  end
end

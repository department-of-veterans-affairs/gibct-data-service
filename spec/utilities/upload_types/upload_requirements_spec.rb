# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadTypes::UploadRequirements do
  def validations(csv_class, requirement_class)
    csv_class.validators
             .find { |requirements| requirements.instance_of?(requirement_class) }
  end

  def map_attributes(csv_class, requirement_class)
    validations(csv_class, requirement_class)
      .attributes
      .map { |column| csv_class::CSV_CONVERTER_INFO.select { |_k, v| v[:column] == column }.keys.join(', ') }
  end

  def skip_unless_validates(example_klass, validator)
    testable_klasses = ImportableRecord.subclasses.select do |klass|
      described_class.send(:klass_validator, validator, klass).any?
    end

    unless testable_klasses.include?(example_klass)
      msg = "Cannot test without an ImportableRecord that implements #{validator.name.demodulize}"
      msg << ". Refactor test to use one of following: #{testable_klasses.join(', ')}" if testable_klasses.any?
      skip msg
    end
  end

  describe 'requirements_messages' do
    it 'returns validates numericality messages' do
      validations_of_str = ['facility code', 'institution name', 'institution country']
      message = { message: 'These columns must have a value: ', value: validations_of_str }
      messages = described_class.requirements_messages(Weam)
      expect(messages).to include(message)
    end

    it 'returns validates uniqueness messages' do
      # CalculatorConstant no longer ImportableRecord, skip unless another record type viable to test uniqueness validator
      skip_unless_validates(CalculatorConstant, ActiveRecord::Validations::UniquenessValidator)

      validations_of_str = map_attributes(CalculatorConstant, ActiveRecord::Validations::UniquenessValidator)
      message = { message: 'These columns should contain unique values: ', value: validations_of_str }
      messages = described_class.requirements_messages(CalculatorConstant)
      expect(messages).to include(message)
    end

    it 'returns validates presence messages' do
      validations_of_str = ['facility code', 'description']
      message = { message: 'These columns must have a value: ', value: validations_of_str }
      messages = described_class.requirements_messages(Program)
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

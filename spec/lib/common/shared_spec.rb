# frozen_string_literal: true

require 'rails_helper'

describe Common::Shared do
  describe 'klass' do
    it 'returns class object' do
      expect(Institution.klass).to eq(Institution)
    end
  end

  describe 'file_type_default' do
    it 'returns generic options' do
      generic_options = Rails.application.config.csv_defaults['generic'].transform_keys(&:to_sym)
      expect(described_class.file_type_defaults(CalculatorConstant.name))
        .to eq(generic_options)
    end

    it 'returns class specific options' do
      program_options = described_class.file_type_defaults(Program.name)
      expect(program_options[:col_sep]).to eq('|')
    end

    it 'returns overridden options' do
      program_options = described_class.file_type_defaults(Program.name, { skip_lines: 1 })
      expect(program_options[:col_sep]).to eq('|')
      expect(program_options[:skip_lines]).to eq(1)
    end
  end

  describe 'convert_csv_header' do
    it 'replaces - with underscores' do
      header = 'a-header--to--&--test'
      expect(described_class.convert_csv_header(header)).to eq('a_header_to_&_test')
    end

    it 'replaces spaces with underscores' do
      header = 'a header to  &  test'
      expect(described_class.convert_csv_header(header)).to eq('a_header_to_&_test')
    end
  end
end

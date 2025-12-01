# frozen_string_literal: true

require 'rails_helper'

describe Common::Shared do
  describe 'klass' do
    it 'returns class object' do
      expect(Institution.klass).to eq(Institution)
    end
  end

  describe 'file_type_defaults' do
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

    it 'strips UTF-8 BOM characters (raw bytes)' do
      # UTF-8 BOM: \xEF\xBB\xBF
      header_with_bom = "\xEF\xBB\xBFUnitId"
      expect(described_class.convert_csv_header(header_with_bom)).to eq('UnitId')
    end

    it 'strips UTF-16/UTF-32 BOM characters' do
      # Unicode BOM: \uFEFF
      header_with_bom = "\uFEFFUnitId"
      expect(described_class.convert_csv_header(header_with_bom)).to eq('UnitId')
    end

    it 'strips UTF-8 BOM misread as ISO-8859-1' do
      # UTF-8 BOM misread as ISO-8859-1: ï»¿
      header_with_bom = "ï»¿UnitId"
      expect(described_class.convert_csv_header(header_with_bom)).to eq('UnitId')
    end

    it 'handles BOM with spaces and dashes correctly' do
      # BOM followed by header with spaces/dashes
      header_with_bom = "\xEF\xBB\xBFUnit-Id Header"
      expect(described_class.convert_csv_header(header_with_bom)).to eq('Unit_Id_Header')
    end

    it 'handles headers without BOM normally' do
      header = 'UnitId'
      expect(described_class.convert_csv_header(header)).to eq('UnitId')
    end
  end

  describe 'display_csv_header' do
    it 'replaces underscores with spaces' do
      header = 'a_header_to_&_test'
      expect(described_class.display_csv_header(header)).to eq('a header to & test')
    end
  end
end

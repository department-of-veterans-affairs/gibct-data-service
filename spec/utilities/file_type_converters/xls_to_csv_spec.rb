# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FileTypeConverters::XlsToCsv do
  describe '#initialize' do
    it 'sets the input and output files to their respective instance variables' do
      xtc = described_class.new('tmp/excel_file.xls', 'tmp/comma_sep_val_file.csv')
      expect(xtc.xls_file_name).to eq('tmp/excel_file.xls')
      expect(xtc.csv_file_name).to eq('tmp/comma_sep_val_file.csv')
    end
  end

  describe '#convert_xls_to_csv' do
    it 'converts an xls file to a csv file' do
      File.delete('tmp/eight_key.csv') if File.exist?('tmp/eight_key.csv')
      described_class.new('spec/fixtures/download_8_keys_sites.xls', 'tmp/eight_key.csv').convert_xls_to_csv
      expect(File.exist?('tmp/eight_key.csv')).to be true
    end

    it 'convert numbers to strings, but does not pad them with zeros' do
      File.delete('tmp/eight_key.csv') if File.exist?('tmp/eight_key.csv')
      described_class.new('spec/fixtures/download_8_keys_sites.xls', 'tmp/eight_key.csv').convert_xls_to_csv
      expect(File.exist?('tmp/eight_key.csv')).to be true
      csv_data = CSV.read('tmp/eight_key.csv')
      expect(csv_data[2][4]).to eq('100200')
    end
  end
end

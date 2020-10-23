# frozen_string_literal: true

require 'rails_helper'

describe RooHelper::Loader do
  let(:edu_program) { EduProgram }
  let(:program) { Program }

  context 'converter_info' do
    let(:key) { 'facility_code'}
    it 'returns correct info object for a header with underscores' do
      info = edu_program.send(:converter_info, edu_program, key)
      expect(info).to eq(edu_program::CSV_CONVERTER_INFO[key])
    end
    it 'returns correct info object for a header with spaces' do
      file_header = 'facility code'
      info = edu_program.send(:converter_info, edu_program, file_header)
      expect(info).to eq(edu_program::CSV_CONVERTER_INFO[key])

    end
    it 'returns correct info object for a header with dashes' do
      file_header = 'facility-code'
      info = edu_program.send(:converter_info, edu_program, file_header)
      expect(info).to eq(edu_program::CSV_CONVERTER_INFO[key])
    end
  end

  context 'header checking' do
    it 'has no missing or extra headers for a normal csv' do
      file_headers = edu_program::CSV_CONVERTER_INFO.keys.map{|k| k.gsub('_', ' ')}
      header_warnings = edu_program.send(:header_warnings, edu_program, file_headers)

      expect(header_warnings).to be_empty
    end

    it 'has missing headers when a csv column is missing' do
      file_headers = edu_program::CSV_CONVERTER_INFO.keys.map{|k| k.gsub('_', ' ')}
      missing_header = file_headers.pop
      header_warnings = edu_program.send(:header_warnings, edu_program, file_headers)

      expect(header_warnings).not_to be_empty
      expect(header_warnings).to include("#{missing_header.capitalize} is a missing header")
    end

    it 'has extra headers when a csv column is added' do
      extra_header = 'extra-header'
      file_headers = edu_program::CSV_CONVERTER_INFO.keys
                         .map{|k| k.gsub('_', ' ')}.push(extra_header)
      header_warnings = edu_program.send(:header_warnings, edu_program, file_headers)

      extra_warning = "#{extra_header.gsub(/\s+|-+/, ' ').capitalize} is an extra header"
      expect(header_warnings).not_to be_empty
      expect(header_warnings).to include(extra_warning)
    end
  end

  context 'merge_options' do
    it 'sets defaults' do
      file_options = {}
      merged_options = edu_program.send(:merge_options, file_options)

      expect(merged_options[:parse_as_xml]).to be_falsey
      sheet_1 = merged_options[:sheets][0]
      expect(sheet_1[:skip_lines]).to eq(0)
      expect(sheet_1[:first_line]).to eq(2)
      expect(sheet_1[:klass]).to eq(edu_program)
    end

    it 'does not override parse_as_xml' do
      file_options = { parse_as_xml: true }
      merged_options = edu_program.send(:merge_options, file_options)

      expect(merged_options[:parse_as_xml]).to be_truthy
    end

    it 'does not override sheets objects' do
      file_options = {sheets: [{klass: program, skip_lines: 2, first_line: 3}]}
      merged_options = program.send(:merge_options, file_options)

      sheet_1 = merged_options[:sheets][0]
      expect(sheet_1[:skip_lines]).to eq(2)
      expect(sheet_1[:first_line]).to eq(3)
      expect(sheet_1[:klass]).to eq(program)
    end

    it 'sets default sheets array object properties' do
      file_options = {sheets: [{klass: program}]}
      merged_options = program.send(:merge_options, file_options)

      sheet_1 = merged_options[:sheets][0]
      expect(sheet_1[:skip_lines]).to eq(0)
      expect(sheet_1[:first_line]).to eq(2)
      expect(sheet_1[:klass]).to eq(program)
    end
  end

  describe 'csv_col_sep' do
    it 'returns , for comma separated values' do
      csv_file = "./spec/fixtures/#{edu_program.name.underscore}.csv"
      file_options = {sheets: [{klass: edu_program}]}

      expect(edu_program.send(:csv_col_sep, csv_file, file_options)).to eq(',')
    end

    it 'returns | for pipe delimited file' do
      csv_file = "./spec/fixtures/#{program.name.underscore}.csv"
      file_options = {sheets: [{klass: program}]}

      expect(program.send(:csv_col_sep, csv_file, file_options)).to eq('|')
    end

    it 'raises error when neither comma or pipe are found' do
      csv_file = "./spec/fixtures/invalid_col_sep.csv"
      file_options = {sheets: [{klass: edu_program, skip_lines: 0}]}

      error_message = 'Unable to determine column separators, valid separators equal "|" and ","'
      expect { edu_program.send(:csv_col_sep, csv_file, file_options) }
          .to raise_error(StandardError, error_message)
    end
  end
end
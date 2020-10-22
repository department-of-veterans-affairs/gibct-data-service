# frozen_string_literal: true

require 'rails_helper'

describe RooHelper::Loader do
  let(:subject) { EduProgram }

  context 'converter_info' do
    let(:key) { 'facility_code'}
    it 'returns correct info object for a header with underscores' do
      info = subject.send(:converter_info, subject, key)
      expect(info).to eq(subject::CSV_CONVERTER_INFO[key])
    end
    it 'returns correct info object for a header with spaces' do
      file_header = 'facility code'
      info = subject.send(:converter_info, subject, file_header)
      expect(info).to eq(subject::CSV_CONVERTER_INFO[key])

    end
    it 'returns correct info object for a header with dashes' do
      file_header = 'facility-code'
      info = subject.send(:converter_info, subject, file_header)
      expect(info).to eq(subject::CSV_CONVERTER_INFO[key])
    end
  end

  # describe 'header checking' do
  #   it 'has no missing or extra headers for a normal csv' do
  #     upload.check_for_headers
  #
  #     expect(upload.missing_headers).to be_empty
  #     expect(upload.extra_headers).to be_empty
  #   end
  #
  #   it 'has missing headers when a csv column is missing' do
  #     upload = build :upload, csv_name: 'weam_missing_column.csv'
  #     upload.check_for_headers
  #
  #     expect(upload.missing_headers).not_to be_empty
  #     expect(upload.extra_headers).to be_empty
  #   end
  #
  #   it 'has extra headers when a csv column is added' do
  #     upload = build :upload, csv_name: 'weam_extra_column.csv'
  #     upload.check_for_headers
  #
  #     expect(upload.missing_headers).to be_empty
  #     expect(upload.extra_headers).not_to be_empty
  #   end
  #
  #   context 'with insufficient information' do
  #     it 'has no missing or extra headers if upload_file not valid' do
  #       upload.upload_file = nil
  #       upload.check_for_headers
  #
  #       expect(upload.missing_headers).to be_empty
  #       expect(upload.extra_headers).to be_empty
  #     end
  #
  #     it 'has no missing or extra headers if csv_type not valid' do
  #       upload.csv_type = nil
  #       upload.check_for_headers
  #
  #       expect(upload.missing_headers).to be_empty
  #       expect(upload.extra_headers).to be_empty
  #     end
  #
  #     it 'has no missing or extra headers if skip_lines is not valid' do
  #       upload.skip_lines = nil
  #       upload.check_for_headers
  #
  #       expect(upload.missing_headers).to be_empty
  #       expect(upload.extra_headers).to be_empty
  #     end
  #   end
  # end

  # describe 'set_col_sep' do
  #   it 'sets col_sep to comma when csv first line' do
  #     first_line = 'a,b,c'
  #     upload = build :upload
  #     upload.send(:set_col_sep, first_line)
  #     expect(upload.col_sep).to eq(',')
  #   end
  #
  #   it 'sets col_sep to pipe when pipe delimited first line and contains a comma in a column' do
  #     first_line = 'a|,b|c'
  #     upload = create :upload
  #     upload.send(:set_col_sep, first_line)
  #     expect(upload.col_sep).to eq('|')
  #   end
  #
  #   it 'raises error when neither comma or pipe are found' do
  #     first_line = 'a/b\c'
  #     upload = create :upload
  #     error_message = 'Unable to determine column separators, valid separators equal "|" and ","'
  #     expect { upload.send(:set_col_sep, first_line) }.to raise_error(StandardError, error_message)
  #   end
  # end
end
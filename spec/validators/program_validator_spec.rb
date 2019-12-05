# frozen_string_literal: true

require 'rspec'

describe ProgramValidator do
  describe 'after_import_batch_validations' do
    context 'when record is unique and facility_code is present in Weam table' do
      it 'passes validation' do
        weam = create :weam
        create :program, facility_code: weam.facility_code

        validation_warnings = []
        described_class.after_import_batch_validations(validation_warnings)
        expect(validation_warnings).to be_empty
      end
    end

    context 'when record does not have unique facility_code & description values' do
      def check_error_messages(validation_warnings)
        validation_warnings.each_with_index do |warning, index|
          expect(warning[:message])
            .to include('The Facility Code & Description (Program Name) combination is not unique:')

          expect(warning[:message]).to include("Line #{index}")
        end
      end

      it 'fails validation' do
        weam = create :weam
        create :program, facility_code: weam.facility_code, csv_row: 0
        create :program, facility_code: weam.facility_code, csv_row: 1
        validation_warnings = []
        described_class.after_import_batch_validations(validation_warnings)

        expect(validation_warnings).not_to be_empty
        check_error_messages(validation_warnings)
      end
    end

    context 'when record has invalid facility code error message' do
      def check_error_messages(validation_warnings)
        validation_warnings.each_with_index do |warning, index|
          expect(warning[:message]).to include('The Facility Code ')
          expect(warning[:message]).to include('is not contained within the most recently uploaded weams.csv')

          expect(warning[:message]).to include("Line #{index}")
        end
      end

      it 'fails validation' do
        create :program, facility_code: 0o0, csv_row: 0
        validation_warnings = []

        described_class.after_import_batch_validations(validation_warnings)

        expect(validation_warnings).not_to be_empty

        check_error_messages(validation_warnings)
      end
    end
  end
end

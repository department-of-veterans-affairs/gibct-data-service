# frozen_string_literal: true

require 'rspec'

describe ProgramValidator do
  describe 'after_import_batch_validations' do
    context 'when record is unique and facility_code is present in Weam table' do
      it 'passes validation' do
        weam = create :weam
        create :program, facility_code: weam.facility_code

        failed_instances = []
        described_class.after_import_batch_validations(failed_instances)
        expect(failed_instances).to be_empty
      end
    end

    context 'when record does not have unique facility_code & description values' do
      def check_error_messages(failed_instances)
        failed_instances.each_with_index do |record, index|
          expect(record.display_errors_with_row)
            .to include('The Facility Code & Description (Program Name) combination is not unique:')

          expect(record.display_errors_with_row).to include("Row #{index}")
        end
      end

      it 'fails validation' do
        weam = create :weam
        create :program, facility_code: weam.facility_code, csv_row: 0
        create :program, facility_code: weam.facility_code, csv_row: 1
        failed_instances = []
        described_class.after_import_batch_validations(failed_instances)

        expect(failed_instances).not_to be_empty
        check_error_messages(failed_instances)
      end
    end

    context 'when record has invalid facility code error message' do
      def check_error_messages(failed_instances)
        failed_instances.each_with_index do |record, index|
          expect(record.display_errors_with_row).to include('The Facility Code ')
          expect(record.display_errors_with_row)
            .to include('is not contained within the most recently uploaded weams.csv')

          expect(record.display_errors_with_row).to include("Row #{index}")
        end
      end

      it 'fails validation' do
        create :program, facility_code: 0o0, csv_row: 0
        failed_instances = []

        described_class.after_import_batch_validations(failed_instances)

        expect(failed_instances).not_to be_empty

        check_error_messages(failed_instances)
      end
    end
  end
end

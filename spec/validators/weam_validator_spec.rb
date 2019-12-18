# frozen_string_literal: true

require 'rspec'

describe WeamValidator do
  let(:row_offset) { 2 }

  describe 'after_import_batch_validations' do
    context 'when facility_code is unique' do
      it 'passes validation' do
        create :weam

        failed_instances = []
        described_class.after_import_batch_validations(failed_instances)
        expect(failed_instances).to be_empty
      end
    end

    context 'when record does not have unique facility_code' do
      def check_error_messages(failed_instances)
        failed_instances.each_with_index do |record, index|
          expect(record.display_errors_with_row)
            .to include('The Facility Code is not unique:')

          expect(record.display_errors_with_row).to include("Row #{index + row_offset}")
        end
      end

      it 'fails validation' do
        weam = create :weam, csv_row: row_offset
        create :weam, facility_code: weam.facility_code, csv_row: row_offset + 1

        failed_instances = []
        described_class.after_import_batch_validations(failed_instances)

        expect(failed_instances).not_to be_empty
        check_error_messages(failed_instances)
      end
    end
  end
end

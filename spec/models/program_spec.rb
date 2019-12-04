# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Program, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:program) { build :program }

    it 'has a valid factory' do
      expect(program).to be_valid
    end

    it 'requires a valid facility_code' do
      expect(build(:program, facility_code: nil)).not_to be_valid
    end

    it 'requires a valid program_type' do
      expect(build(:program, program_type: 'NCD')).to be_valid
    end
  end

  describe 'after_import_batch_validations' do
    context 'when record is unique and facility_code is present in Weam table' do
      it 'passes validation' do
        weam = create :weam
        program = create :program, facility_code: weam.facility_code

        failed_instances = []
        described_class.after_import_batch_validations([program], failed_instances, 0)
        expect(failed_instances).to be_empty
      end
    end

    context 'when record does not have unique facility_code & description values' do
      def check_error_messages(failed_instances, row_offset)
        failed_instances.each_with_index do |warning, index|
          expect(warning[:message]).to include('The Facility Code & Description (Program Name) combination is not unique:')

          expect(warning[:message]).to include("Line #{index + row_offset}")
        end
      end

      it 'fails validation' do
        weam = create :weam
        program = create :program, facility_code: weam.facility_code, csv_row: 0
        program_b = create :program, facility_code: weam.facility_code, csv_row: 1
        records = [program, program_b]
        failed_instances = []
        row_offset = 0

        described_class.after_import_batch_validations(records, failed_instances, row_offset)

        expect(failed_instances).not_to be_empty

        check_error_messages(failed_instances, row_offset)
      end
    end

    context 'when record has invalid facility code error message' do
      def check_error_messages(failed_instances, row_offset)
        failed_instances.each_with_index do |warning, index|
          expect(warning[:message]).to include('The Facility Code ')
          expect(warning[:message]).to include('is not contained within the most recently uploaded weams.csv')

          expect(warning[:message]).to include("Line #{index + row_offset}")
        end
      end

      it 'fails validation' do
        program = create :program, facility_code: 0o0, csv_row: 0
        records = [program]
        failed_instances = []
        row_offset = 0

        described_class.after_import_batch_validations(records, failed_instances, row_offset)

        expect(failed_instances).not_to be_empty

        check_error_messages(failed_instances, row_offset)
      end
    end
  end
end

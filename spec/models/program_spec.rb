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
      def check_error_messages(records, row_offset)
        records.each_with_index do |record, index|
          error_messages = record.errors.messages
          expect(error_messages.any?).to eq(true)

          error_message = 'The Facility Code & Description (Program Name) combination is not unique:' \
"\n#{record.facility_code}, #{record.description}"
          expect(error_messages[:base]).to include(error_message)

          expect(error_messages[:row]).to include("Line #{index + row_offset}")
        end
      end

      it 'fails validation' do
        program = create :program
        program_b = create :program, facility_code: program.facility_code
        records = [program, program_b]
        failed_instances = []
        row_offset = 0

        described_class.after_import_batch_validations(records, failed_instances, row_offset)

        expect(failed_instances).not_to be_empty

        check_error_messages(records, row_offset)
      end
    end

    context 'when record has invalid facility code error message' do
      def check_error_messages(records, row_offset)
        records.each_with_index do |record, index|
          error_messages = record.errors.messages
          expect(error_messages.any?).to eq(true)

          error_message =
            "The Facility Code #{record.facility_code} " \
      'is not contained within the most recently uploaded weams.csv'
          expect(error_messages[:base]).to include(error_message)

          expect(error_messages[:row]).to include("Line #{index + row_offset}")
        end
      end

      it 'fails validation' do
        program = create :program, facility_code: 0o0
        program_b = create :program, facility_code: program.facility_code
        records = [program, program_b]
        failed_instances = []
        row_offset = 0

        described_class.after_import_batch_validations(records, failed_instances, row_offset)

        expect(failed_instances).not_to be_empty

        check_error_messages(records, row_offset)
      end
    end
  end
end

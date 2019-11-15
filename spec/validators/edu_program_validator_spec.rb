# frozen_string_literal: true

require 'rspec'

describe EduProgramValidator do
  describe '#validate' do
    context 'when record is unique and facility_code is present in Weam table' do
      it 'passes validation' do
        edu_program = create :edu_program
        expect(edu_program).to be_valid
      end
    end

    context 'when record does not have unique facility_code & vet_tec_program values' do
      def check_invalid_programs(edu_program, edu_program_b)
        expect(edu_program.valid?(:after_import)).to eq(false)
        expect(edu_program_b.valid?(:after_import)).to eq(false)
      end

      def check_error_messages(edu_program)
        error_messages = edu_program.errors.messages
        expect(error_messages.any?).to eq(true)
        error_message = 'The Facility Code & VET TEC Program (Program Name) combination is not unique:' \
"\n#{edu_program.facility_code}, #{edu_program.vet_tec_program}"
        expect(error_messages[:base]).to include(error_message)
      end

      it 'fails validation' do
        edu_program = create :edu_program
        edu_program_b = create :edu_program, facility_code: edu_program.facility_code
        check_invalid_programs(edu_program, edu_program_b)
        check_error_messages(edu_program)
      end
    end

    context 'when record has invalid facility code error message' do
      def check_invalid_code_messages(edu_program)
        error_messages = edu_program.errors.messages
        expect(error_messages.any?).to eq(true)
        error_message =
          "The Facility Code #{edu_program.facility_code} " \
          'is not contained within the most recently uploaded weams.csv'

        expect(error_messages[:base]).to include(error_message)
      end

      it 'fails validation' do
        edu_program = create :edu_program, facility_code: 0o0
        expect(edu_program.valid?(:after_import)).to eq(false)
        check_invalid_code_messages(edu_program)
      end
    end

    context 'when record has no facility code error message' do
      def check_invalid_code_messages(edu_program)
        error_messages = edu_program.errors.messages
        expect(error_messages.any?).to eq(true)
        error_message =
            "The Facility Code is blank:"

        expect(error_messages[:base]).to include(error_message)
      end

      it 'fails validation' do
        edu_program = create :edu_program, facility_code: nil
        expect(edu_program.valid?(:after_import)).to eq(false)
        check_invalid_code_messages(edu_program)
      end
    end

    context 'when record has no vet_tec_program error message' do
      def check_invalid_code_messages(edu_program)
        error_messages = edu_program.errors.messages
        expect(error_messages.any?).to eq(true)
        error_message =
            "The VET TEC Program (Program Name) is blank:"

        expect(error_messages[:base]).to include(error_message)
      end

      it 'fails validation' do
        edu_program = create :edu_program, vet_tec_program: nil
        expect(edu_program.valid?(:after_import)).to eq(false)
        check_invalid_code_messages(edu_program)
      end
    end
  end
end

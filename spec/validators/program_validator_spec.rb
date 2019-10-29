# frozen_string_literal: true

require 'rspec'

describe ProgramValidator do
  describe '#validate' do
    context 'when record is unique and facility_code is present in Weam table' do
      it 'passes validation' do
        program = create :program

        expect(program).to be_valid
      end
    end

    context 'when record does not have unique facility_code & description values' do
      def check_invalid_programs(program, program_b)
        expect(program.valid?(:after_import)).to eq(false)
        expect(program_b.valid?(:after_import)).to eq(false)
      end

      def check_error_messages(program)
        error_messages = program.errors.messages
        expect(error_messages.any?).to eq(true)
        error_message = 'The Facility Code & Description (Program Name) combination is not unique:' \
"\n#{program.facility_code}, #{program.description}"
        expect(error_messages[:base]).to include(error_message)
      end

      it 'fails validation' do
        program = create :program
        program_b = create :program, facility_code: program.facility_code
        check_invalid_programs(program, program_b)
        check_error_messages(program)
      end
    end

    context 'when record has invalid facility code error message' do
      def check_invalid_code_messages(program)
        error_messages = program.errors.messages
        expect(error_messages.any?).to eq(true)
        error_message =
          "The Facility Code #{program.facility_code} " \
        'is not contained within the most recently uploaded weams.csv'
        expect(error_messages[:base]).to include(error_message)
      end

      it 'fails validation' do
        program = create :program, facility_code: 0o0
        expect(program.valid?(:after_import)).to eq(false)
        check_invalid_code_messages(program)
      end
    end
  end
end

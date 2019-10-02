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
      it 'fails validation' do
        program = create :program
        program_b = create :program, facility_code: program.facility_code

        expect(program.valid?(:after_import)).to eq(false)
        expect(program_b.valid?(:after_import)).to eq(false)

        error_messages = program.errors.messages
        expect(error_messages.any?).to eq(true)

        error_message = "The Facility Code & Description (Program Name) combination is not unique:
#{program.facility_code}, #{program.description}"
        expect(error_messages[:base]).to include(error_message)
      end
    end

    context 'when record has invalid facility code error message' do
      it 'fails validation' do
        program = create :program, facility_code: 0o0

        expect(program.valid?(:after_import)).to eq(false)

        error_messages = program.errors.messages
        expect(error_messages.any?).to eq(true)

        error_message =
          "The Facility Code #{program.facility_code} is not contained within the most recently uploaded weams.csv"

        expect(error_messages[:base]).to include(error_message)
      end
    end
  end
end

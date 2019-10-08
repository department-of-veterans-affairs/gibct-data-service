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
      it 'fails validation' do
        edu_program = create :edu_program
        edu_program_b = create :edu_program, facility_code: edu_program.facility_code

        expect(edu_program.valid?(:after_import)).to eq(false)
        expect(edu_program_b.valid?(:after_import)).to eq(false)

        error_messages = edu_program.errors.messages
        expect(error_messages.any?).to eq(true)

        error_message = "The Facility Code & VET TEC Program (Program Name) combination is not unique:
#{edu_program.facility_code}, #{edu_program.vet_tec_program}"

        expect(error_messages[:base]).to include(error_message)
      end
    end

    context 'when record has invalid facility code error message' do
      it 'fails validation' do
        edu_program = create :edu_program, facility_code: 0o0

        expect(edu_program.valid?(:after_import)).to eq(false)

        error_messages = edu_program.errors.messages
        expect(error_messages.any?).to eq(true)

        error_message =
          "The Facility Code #{edu_program.facility_code} is not contained within the most recently uploaded weams.csv"

        expect(error_messages[:base]).to include(error_message)
      end
    end
  end
end

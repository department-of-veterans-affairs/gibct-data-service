# frozen_string_literal: true

require 'rspec'

describe EduProgramValidator do
  describe 'when validating for load_csv context' do
    it 'has no errors' do
      edu_program = create :edu_program

      expect(edu_program).to be_valid
    end

    it 'has invalid facility_code & vet_tec_program error message' do
      edu_program = create :edu_program
      edu_program_b = create :edu_program, facility_code: edu_program.facility_code

      expect(edu_program.valid?(:load_csv)).to eq(false)
      expect(edu_program_b.valid?(:load_csv)).to eq(false)

      error_messages = edu_program.errors.messages
      expect(error_messages.any?).to eq(true)

      error_message = "The Facility Code & VET TEC Program (Program Name) combination is not unique:
#{edu_program.facility_code}, #{edu_program.vet_tec_program}"
      expect(error_messages[:base]).to include(error_message)
    end

    it 'has invalid facility code error message' do
      edu_program = create :edu_program, facility_code: 0o0

      expect(edu_program.valid?(:load_csv)).to eq(false)

      error_messages = edu_program.errors.messages
      expect(error_messages.any?).to eq(true)

      error_message =
        "The Facility Code #{edu_program.facility_code} is not contained within the most recently uploaded weams.csv"

      expect(error_messages[:base]).to include(error_message)
    end
  end
end

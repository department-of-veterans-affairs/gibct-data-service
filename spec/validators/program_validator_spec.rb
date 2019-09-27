# frozen_string_literal: true

require 'rspec'

describe ProgramValidator do
  describe 'when validating for load_csv context' do
    it 'has no errors' do
      program = create :program

      expect(program).to be_valid
    end

    it 'has invalid facility code & description error message' do
      program = create :program
      program_b = create :program, facility_code: program.facility_code

      expect(program.valid?(:load_csv)).to eq(false)
      expect(program_b.valid?(:load_csv)).to eq(false)

      error_messages = program.errors.messages
      expect(error_messages.any?).to eq(true)

      error_message = "The Facility Code & Description (Program Name) combination is not unique:
#{program.facility_code}, #{program.description}"
      expect(error_messages[:base]).to include(error_message)
    end

    it 'has invalid facility code error message' do
      program = create :program, facility_code: 0o0

      expect(program.valid?(:load_csv)).to eq(false)

      error_messages = program.errors.messages
      expect(error_messages.any?).to eq(true)

      error_message = "The Facility Code #{program.facility_code} is not
contained within the most recently uploaded weams.csv"

      expect(error_messages[:base]).to include(error_message)
    end
  end
end

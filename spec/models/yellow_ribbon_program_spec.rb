# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe YellowRibbonProgram, type: :model do
  describe 'when validating' do
    subject(:yellow_ribbon_program) { build :yellow_ribbon_program }

    before do
      create(:version, :production)
    end

    it 'has a valid factory' do
      expect(yellow_ribbon_program).to be_valid
    end

    it 'expects a facility code' do
      expect(build(:yellow_ribbon_program, facility_code: nil)).not_to be_valid
    end

    it 'expects a degree level' do
      expect(build(:yellow_ribbon_program, degree_level: nil)).not_to be_valid
    end

    it 'expects a division or professional school name' do
      expect(build(:yellow_ribbon_program, division_professional_school: nil)).not_to be_valid
    end

    it 'expects numeric number of students' do
      expect(build(:yellow_ribbon_program, number_of_students: nil)).not_to be_valid
      expect(build(:yellow_ribbon_program, number_of_students: 'somestring')).not_to be_valid
    end

    it 'expects numeric contribution amount' do
      expect(build(:yellow_ribbon_program, contribution_amount: nil)).not_to be_valid
      expect(build(:yellow_ribbon_program, contribution_amount: 'somestring')).not_to be_valid
    end
  end
end

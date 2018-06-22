# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe YellowRibbonProgramSource, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject { build :yellow_ribbon_program_source }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'expects a facility code' do
      expect(build(:yellow_ribbon_program_source, facility_code: nil)).not_to be_valid
    end

    it 'expects a degree level' do
      expect(build(:yellow_ribbon_program_source, degree_level: nil)).not_to be_valid
    end

    it 'expects a division or professional school name' do
      expect(build(:yellow_ribbon_program_source, division_professional_school: nil)).not_to be_valid
    end

    it 'expects numeric number of students' do
      expect(build(:yellow_ribbon_program_source, number_of_students: nil)).not_to be_valid
      expect(build(:yellow_ribbon_program_source, number_of_students: 'somestring')).not_to be_valid
    end

    it 'expects numeric contribution amount' do
      expect(build(:yellow_ribbon_program_source, contribution_amount: nil)).not_to be_valid
      expect(build(:yellow_ribbon_program_source, contribution_amount: 'somestring')).not_to be_valid
    end
  end
end

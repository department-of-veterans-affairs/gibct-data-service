# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe EduProgram, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:edu_program) { build :edu_program }

    it 'has a valid factory' do
      expect(edu_program).to be_valid
    end

    it 'is invalid without a facility_code' do
      edu_program.facility_code = nil
      expect(edu_program).not_to be_valid
    end
  end
end

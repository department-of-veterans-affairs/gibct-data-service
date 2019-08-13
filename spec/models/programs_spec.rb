# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Programs, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject { build :programs }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires a valid facility_code' do
      expect(build(:programs, facility_code: nil)).not_to be_valid
    end

    it 'requires a valid program_type' do
      expect(build(:programs, program_type: 'NCD')).to be_valid
    end
  end
end

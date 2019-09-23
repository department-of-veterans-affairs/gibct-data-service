# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Program, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject { build :program }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires a valid facility_code' do
      expect(build(:program, facility_code: nil)).not_to be_valid
    end

    it 'requires a valid program_type' do
      expect(build(:program, program_type: 'NCD')).to be_valid
    end
  end

  describe 'when validating for load_csv context' do
    subject { build :program }

    it 'has no errors' do

    end
  end
end

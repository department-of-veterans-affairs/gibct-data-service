# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe AccreditationInstituteCampus, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject { build :accreditation_institute_campus }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'computes the ope6 from ope' do
      expect(subject.ope6).to eq(subject.ope[1, 5])
    end
  end
end

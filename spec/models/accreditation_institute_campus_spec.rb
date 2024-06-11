# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe AccreditationInstituteCampus, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:accreditation_institute_campus) { build :accreditation_institute_campus }

    it 'has a valid factory' do
      expect(accreditation_institute_campus).to be_valid
    end

    it 'is not valid without a dapip id' do
      accreditation_institute_campus.dapip_id = nil
      expect(accreditation_institute_campus).not_to be_valid
    end

    it 'computes the ope6 from ope' do
      expect(accreditation_institute_campus.ope6).to eq(accreditation_institute_campus.ope[1, 5])
    end
  end
end

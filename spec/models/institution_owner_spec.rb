# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe InstitutionOwner, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:institution_owner) { build :institution_owner }

    it 'has a valid factory' do
      expect(institution_owner).to be_valid
    end

    it 'fails validation when facility_code is not present' do
      institution_owner.facility_code = nil
      expect(institution_owner).not_to be_valid
    end

    it 'fails validation when institution is not present' do
      institution_owner.institution_name = nil
      expect(institution_owner).not_to be_valid
    end
  end
end

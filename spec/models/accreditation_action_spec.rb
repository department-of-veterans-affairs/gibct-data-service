# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe AccreditationAction, type: :model do
  before { create(:accreditation_institute_campus) }

  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:accreditation_action) { build :accreditation_action }

    it 'has a valid factory' do
      expect(accreditation_action).to be_valid
    end

    it 'is not valid without a dapip id' do
      accreditation_action.dapip_id = nil
      expect(accreditation_action).not_to be_valid
    end

    it 'is not valid without an agency id' do
      accreditation_action.agency_id = nil
      expect(accreditation_action).not_to be_valid
    end

    it 'is not valid without an agency name' do
      accreditation_action.agency_name = nil
      expect(accreditation_action).not_to be_valid
    end

    it 'is not valid without a program id' do
      accreditation_action.program_id = nil
      expect(accreditation_action).not_to be_valid
    end

    it 'is not valid without an action description' do
      accreditation_action.action_description = nil
      expect(accreditation_action).not_to be_valid
    end

    it 'is not valid without an justification description' do
      accreditation_action.justification_description = nil
      expect(accreditation_action).not_to be_valid
    end
  end
end

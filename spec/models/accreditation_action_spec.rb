# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe AccreditationAction, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:accreditation_action) { build :accreditation_action }

    it 'has a valid factory' do
      expect(accreditation_action).to be_valid
    end
  end
end

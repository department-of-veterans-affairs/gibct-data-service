# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe VrrapProvider, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 1
  it_behaves_like 'an exportable model', skip_lines: 1

  describe 'when validating' do
    subject(:vrrap_provider) { build :vrrap_provider }

    it 'has a valid factory' do
      expect(vrrap_provider).to be_valid
    end

    it 'requires a valid facility_code' do
      expect(build(:vrrap_provider, facilty_code: nil)).not_to be_valid
    end

    it 'requires vaco' do
      expect(build(:vrrap_provider, vaco: nil)).not_to be_valid
    end
  end
end

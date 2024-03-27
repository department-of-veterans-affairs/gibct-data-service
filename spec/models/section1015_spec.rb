# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Section1015, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:section1015) { build :section1015 }

    it 'has a valid factory' do
      expect(section1015).to be_valid
    end

    it 'requires a valid facility code' do
      expect(build(:section1015, facility_code: nil)).not_to be_valid
    end
  end
end

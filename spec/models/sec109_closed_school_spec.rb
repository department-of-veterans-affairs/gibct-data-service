# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Sec109ClosedSchool, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:sec109_closed_school) { build :sec109_closed_school }

    it 'has a valid factory' do
      expect(sec109_closed_school).to be_valid
    end

    it 'requires a valid facility_code' do
      expect(build(:sec109_closed_school, facility_code: nil)).not_to be_valid
    end
  end
end

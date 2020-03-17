require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Sec103, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:sec103) { build :sec103 }

    it 'has a valid factory' do
      expect(sec103).to be_valid
    end

    it 'requires a valid facility code' do
      expect(build(:sec103, facility_code: nil)).not_to be_valid
    end
  end
end
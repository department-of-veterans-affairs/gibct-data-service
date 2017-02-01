require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe Vsoc, type: :model do
  it_behaves_like 'a standardizable model', Vsoc

  describe 'When creating' do
    context 'with a factory' do
      it 'that factory is valid' do
        expect(create(:vsoc)).to be_valid
      end
    end

    context 'facility code' do
      subject { create :vsoc }

      it 'is unique' do
        expect(build :vsoc, facility_code: subject.facility_code).not_to be_valid
      end

      it 'is required' do
        expect(build :vsoc, facility_code: nil).not_to be_valid
      end
    end
  end
end

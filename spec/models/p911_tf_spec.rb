require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe P911Tf, type: :model do
  it_behaves_like 'a standardizable model', P911Tf

  describe 'When creating' do
    context 'with a factory' do
      it 'that factory is valid' do
        expect(create(:p911_tf)).to be_valid
      end
    end

    context 'facility_code' do
      subject { create :p911_tf }

      it 'is unique' do
        expect(build :p911_tf, facility_code: subject.facility_code).not_to be_valid
      end

      it 'is required' do
        expect(build :p911_tf, facility_code: nil).not_to be_valid
      end
    end

    context 'p911_recipients' do
      it 'must be an number' do
        expect(build :p911_tf, p911_recipients: 'abc').not_to be_valid
      end

      it 'is required' do
        expect(build :p911_tf, p911_recipients: nil).not_to be_valid
      end
    end

    context 'p911_tuition_fees' do
      it 'must be a number' do
        expect(build :p911_tf, p911_tuition_fees: 'abc').not_to be_valid
      end

      it 'are required' do
        expect(build :p911_tf, p911_tuition_fees: nil).not_to be_valid
      end
    end
  end
end

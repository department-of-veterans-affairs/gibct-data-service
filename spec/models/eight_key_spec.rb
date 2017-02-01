require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe EightKey, type: :model do
  it_behaves_like 'a standardizable model', EightKey

  describe 'When creating' do
    context 'with a factory' do
      it 'that factory is valid' do
        expect(create(:eight_key)).to be_valid
      end
    end
  end
end

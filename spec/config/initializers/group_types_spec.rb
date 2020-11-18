# frozen_string_literal: true

RSpec.describe 'GROUP_TYPES' do
  describe 'all_tables' do
    it 'lengths should be equal' do
      expect(GROUP_FILE_TYPES.length).to eq(GROUP_FILE_TYPES_NAMES.length)
    end
  end

  describe 'fields checks' do
    GROUP_FILE_TYPES.each do |upload|
      it "#{klass_name(upload)} group type config has types array" do
        expect(upload[:types]).to be_an(Array)
      end
    end
  end
end

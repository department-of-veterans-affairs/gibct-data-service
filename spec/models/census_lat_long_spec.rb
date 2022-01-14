# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CensusLatLong, type: :model do
  describe 'export' do
    it 'returns binary_data' do
      create :version
      create(:institution, :physical_address, version: Version.latest)

      binary_data = described_class.export
      expect(binary_data).to be_present
    end
  end
end

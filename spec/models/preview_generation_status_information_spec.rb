# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreviewGenerationStatusInformation, type: :model do
  describe '.latest' do
    before { create_list(:preview_generation_status_information, 2, :publishing) }

    it 'returns latest model sorted by ID' do
      pgsi = create(:preview_generation_status_information, :publishing)
      expect(described_class.latest).to eq(pgsi)
    end
  end
end

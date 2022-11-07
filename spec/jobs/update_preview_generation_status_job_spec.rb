# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdatePreviewGenerationStatusJob, type: :job do
  describe '#perform' do
    let(:job) { described_class.new }

    it 'adds a row to the database table with the current preview generation status' do
      message = 'Preview Version is being generated.'
      expect { job.perform(message) }.to change(PreviewGenerationStatusInformation, :count).by(1)
    end
  end
end

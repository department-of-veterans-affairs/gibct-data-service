RSpec.describe MessagesHelper, type: :helper do
  describe 'latest_preview_status' do
    before { PreviewGenerationStatusInformation.create(current_progress: 'Starting') }

    it 'returns latest preview generation status information' do
      pgsi = PreviewGenerationStatusInformation.create(current_progress: 'Processing')
      expect(helper.latest_preview_status).to eq(pgsi)
    end
  end

  describe 'preview_generation_started' do
    it 'returns false if no preview generation statuses present' do
      expect(helper.preview_generation_started?).to eq(false)
    end

    it 'returns true if preview generation statuses present' do
      PreviewGenerationStatusInformation.create(current_progress: 'Starting')
      expect(helper.preview_generation_started?).to eq(true)
    end
  end
end
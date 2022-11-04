# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GeneratePreviewJob, type: :job do
  before do
    create :user, email: 'fred@va.gov', password: 'fuggedabodit'
    allow(VetsApi::Service).to receive(:feature_enabled?).and_return(false)
    create(:version, :production)
  end

  describe '#perform' do
    let(:user) { User.first }
    let(:job) { described_class.new(user) }

    it 'creates a new version' do
      expect { job.perform(user) }.to change(Version, :count).by(1)
    end
  end
end

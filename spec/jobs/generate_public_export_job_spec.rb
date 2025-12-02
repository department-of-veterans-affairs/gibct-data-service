# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GeneratePublicExportJob, type: :job do
  describe '#perform' do
    let!(:version) { create(:version, :production) }
    let(:job) { described_class.new }

    before do
      create(:institution, version: version)
    end

    context 'with an existing export' do
      before do
        allow(VersionPublicExport).to receive(:build)
        create(:version_public_export, version: version)
      end

      it 'just returns' do
        job.perform
        expect(VersionPublicExport).not_to have_received(:build)
      end
    end

    context 'without an existing export' do
      it 'creates an export' do
        expect { job.perform }.to change(VersionPublicExport, :count).by(1)
      end
    end
  end
end

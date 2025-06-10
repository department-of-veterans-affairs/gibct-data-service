# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'VersionPublicExports', type: :request do
  describe 'GET #show' do
    let(:version) { create :version, :production }

    before do
      create :version_public_export, version: version
    end

    context 'when getting the latest export' do
      it 'returns the correct file' do
        get version_public_export_path(id: 'latest')
        expect(response.media_type).to eq('application/x-gzip')
        gz = Zlib::GzipReader.new(StringIO.new(response.body.to_s))
        expect(gz.read).to eq("hello\n")
      end
    end

    context 'with a missing export' do
      it 'returns a 404' do
        expect do
          get version_public_export_path(id: '12345')
        end.to raise_error(ActionController::RoutingError)
      end
    end
  end
end

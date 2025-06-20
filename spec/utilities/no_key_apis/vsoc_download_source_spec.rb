# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NoKeyApis::VsocDownloadSource do
  let(:vsoc_page) { File.read('spec/fixtures/vsoc_download_page.html') }
  let(:vsoc_response) { instance_double(HTTParty::Response, body: vsoc_page) }

  before { allow(HTTParty).to receive(:get).and_return(vsoc_response) }

  describe '#initialize' do
    it 'dynamically fetches the href' do
      expect(described_class.new.href).to eq('https://vbaw.vba.va.gov/EDUCATION/job_aids/documents/Vsoc_08132024.csv')
    end
  end

  describe 'when no href is found' do
    let(:vsoc_page_without_link) { '<html><body></body></html>' }
    let(:vsoc_response) { instance_double(HTTParty::Response, body: vsoc_page_without_link) }

    before do
      allow(HTTParty).to receive(:get).and_return(vsoc_response)
      allow(Rails.logger).to receive(:warn)
    end

    it 'returns an empty string and logs a warning' do
      described_class.new.href
      expect(Rails.logger).to have_received(:warn).with('NoKeyApiDownloader: Failed to find VSOC link on page')
      expect(described_class.new.href).to eq('')
    end
  end
end

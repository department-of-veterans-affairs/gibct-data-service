# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NoKeyApis::VsocDownloadSource do
  let(:vsoc_page) { File.read('spec/fixtures/vsoc_download_page.html') }
  let(:vsoc_response) { instance_double(HTTParty::Response, body: vsoc_page) }

  before { allow(HTTParty).to receive(:get).and_return(vsoc_response) }

  describe '#initialize' do
    it "dynamically fetches the href" do
      expect(described_class.new.href).to eq('https://vbaw.vba.va.gov/EDUCATION/job_aids/documents/Vsoc_08132024.csv')
    end
  end
end

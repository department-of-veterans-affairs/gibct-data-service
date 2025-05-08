# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NoKeyApis::DynamicDownloadSource do
  describe '#initialize' do
    it 'cannot be initialized from abstract class' do
      expect { described_class.new('https://example.com') }.to raise_error(NotImplementedError)
    end
  end

  describe '.fetch' do
    let(:ipeds_source_class) { NoKeyApis::IpedsDownloadSource }
    let(:href) { 'https://example.com' }
    let(:ipeds_type) { 'IpedsHd' }

    before do
      page = File.read('spec/fixtures/ipeds_directory_page.txt')
      response_double = instance_double(HTTParty::Response, body: page)
      allow(HTTParty).to receive(:get).and_return(response_double)

      source_double = instance_double(ipeds_source_class, href: href)
      allow(ipeds_source_class).to receive(:new).with(ipeds_type).and_return(source_double)
    end

    it 'instantiates source when called from child class and returns href' do
      expect(ipeds_source_class.fetch(ipeds_type)).to eq(href)
      expect(ipeds_source_class).to have_received(:new).with(ipeds_type)
    end
  end
end

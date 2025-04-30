# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NoKeyApis::DynamicDownloadSource do
  describe '#initialize' do
    it 'cannot be initialized from abstract class' do
      expect { described_class.new('https://example.com') }.to raise_error(NotImplementedError)
    end
  end

  describe '.fetch' do
    subject(:subclass) { NoKeyApis::IpedsDownloadSource }

    let(:page) { File.read('spec/fixtures/ipeds_directory_page.txt') }
    let(:nokogiri_doc) { Nokogiri::HTML(page) }
    let(:source) { instance_double(subclass, scrape_html: nokogiri_doc) }
  
    before { allow(subclass).to receive(:new).and_return(source) }

    it 'collects and then memoizes download sources' do
      byebug
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

# The dummy classes below are defined because code coverage flagged out several methods
# self.fetch(*args)
class DummyDownloadSource < NoKeyApis::DynamicDownloadSource
  def parse_html
    'http://example.com/dummy.csv'
  end
end

# self.class::CACHE_KEY inside the cache_key method
class CacheableDummyDownloadSource < NoKeyApis::DynamicDownloadSource
  CACHE_KEY = 'dummy_html_cache_key'
  def parse_html
    'http://example.com/cached.csv'
  end
end

# self.parse_html
class BrokenDummyDownloadSource < NoKeyApis::DynamicDownloadSource
  # no parse_html method — this will trigger the NotImplementedError
end

# rescue StandardError in scrape_html
class ScrapeFailingDummyDownloadSource < NoKeyApis::DynamicDownloadSource
  def parse_html; end
end

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

    it 'instantiates the subclass and returns the href' do
      expect(DummyDownloadSource.fetch('http://example.com')).to eq('http://example.com/dummy.csv')
    end
  end

  describe '#cache_key' do
    it 'returns the CACHE_KEY constant if defined in subclass' do
      instance = CacheableDummyDownloadSource.new('http://example.com')
      expect(instance.send(:cache_key)).to eq('dummy_html_cache_key')
    end
  end

  describe '#parse_html when the subclass does not implement it' do
    it 'raises NotImplementedError when not implemented in subclass' do
      expect do
        BrokenDummyDownloadSource.new('http://example.com')
      end.to raise_error(NotImplementedError, '#parse_refs must be defined in subclass')
    end
  end

  describe '#scrape_html that throws an exception' do
    it 'rescues StandardError and logs an error if scraping fails' do
      allow(HTTParty).to receive(:get).and_raise(StandardError.new('Boom!'))
      allow(Rails.logger).to receive(:error)

      instance = ScrapeFailingDummyDownloadSource.new('http://example.com')

      expect(Rails.logger).to have_received(:error).with('Error scraping http://example.com: Boom!')
      expect(instance.instance_variable_get(:@html)).to be_nil
    end
  end

  describe '#do_cached_with' do
    it 'calls Rails.cache.fetch with the cache key and yields the block' do
      allow(HTTParty).to receive(:get).and_return(instance_double(HTTParty::Response, body: '<html></html>'))
      allow(Rails.cache).to receive(:fetch)

      CacheableDummyDownloadSource.new('http://example.com')

      expect(Rails.cache).to have_received(:fetch).with('dummy_html_cache_key', expires_in: 1.hour)
    end
  end
end

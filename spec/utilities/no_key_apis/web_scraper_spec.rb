require 'rails_helper'

RSpec.describe NoKeyApis::WebScraper do
  subject(:scraper) { described_class.new(url) }
  let(:url) { 'https://www.example.com' }
  let(:page) { File.read('spec/fixtures/ipeds_directory_page.txt') } 

  describe '.initialize' do
    it 'sets the url value of the web page to be scraped' do
      expect(scraper.url).to eq(url)
    end
  end

  describe '#scrape' do
    it 'converts scraped web page to nokogiri HTML document' do
      response_double = instance_double(HTTParty::Response, body: page)
      allow(HTTParty).to receive(:get).with(url).and_return(response_double)
      expect(scraper.scrape).to be_a(Nokogiri::HTML::Document)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NoKeyApis::IpedsDownloadSource do
  let(:ipeds_page) { File.read('spec/fixtures/ipeds_directory_page.txt') }
  let(:ipeds_response) { instance_double(HTTParty::Response, body: ipeds_page) }

  before { allow(HTTParty).to receive(:get).and_return(ipeds_response) }

  describe '#initialize' do
    %w[IpedsHd IpedsIc IpedsIcAy IpedsIcPy].each do |class_nm|
      it "dynamically fetches href for #{class_nm}" do
        matcher = described_class::MATCHERS[class_nm]
        nokogiri_doc = Nokogiri::HTML(ipeds_page)
        # Grab hrefs from all html links associated with ipeds type
        hrefs = nokogiri_doc.css('.idc_gridviewrow td a')
                            .select { |a| a.text.match?(matcher) }
                            .map { |tag| tag['href'] }
        year_regex = /\d{4}/
        # Confirm multiple links found for ipeds type across different years
        expect(hrefs.map { |h| h.match(year_regex)[0] }).to eq(%w[2023 2022])

        # Expect to dynamically select href of most recent download link
        download_source = "#{described_class::URL}/#{hrefs.first}"
        expect(described_class.new(class_nm).href).to eq(download_source)
      end
    end
  end
end

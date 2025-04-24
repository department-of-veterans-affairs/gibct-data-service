# frozen_string_literal: true

require 'rails_helper'

# These tests show the curl command is constructed properly, but the actual running is stubbed/mocked
# to avoid external dependencies and time to run issues. A suite has been added to test the remote
# calling, but it's advisable to run it from the command line separately and not as part of the test suite

RSpec.describe NoKeyApis::NoKeyApiDownloader do
  let(:ipeds_page) { File.read('spec/fixtures/ipeds_directory_page.txt') }
  let(:nokogiri_doc) { Nokogiri::HTML(ipeds_page) }
  let(:scraper) { instance_double(NoKeyApis::WebScraper, scrape: nokogiri_doc) }

  before { allow(NoKeyApis::WebScraper).to receive(:new).and_return(scraper) }

  describe '#initialize' do
    %w[Accreditation AccreditationAction AccreditationInstituteCampus AccreditationRecord].each do |class_nm|
      it "sets the accreditation curl command correctly for #{class_nm}" do
        nkad = described_class.new(class_nm)
        expect(nkad.class_nm).to eq(class_nm)
        expect(nkad.curl_command).to include('tmp/download.zip')
        expect(nkad.curl_command).to include('-X POST')
        expect(nkad.curl_command).to include('https://ope.ed.gov/dapip/api/downloadFiles/accreditationDataFiles')
        expect(nkad.curl_command).to include("-d '{\"CSVChecked\":true,\"ExcelChecked\":false}'")
      end
    end

    it 'sets the curl command correctly for EightKey' do
      nkad = described_class.new('EightKey')
      expect(nkad.class_nm).to eq('EightKey')
      expect(nkad.curl_command).to include('-X GET')
      expect(nkad.curl_command).to include('tmp/eight_key.xls')
      expect(nkad.curl_command).to include('https://www.ed.gov/sites/ed/files/documents/military/8-keys-sites.xls')
      expect(nkad.curl_command).not_to include('-d')
    end

    %w[IpedsHd IpedsIc IpedsIcAy IpedsIcPy].each do |class_nm|
      it "sets the ipeds curl command correctly for #{class_nm}" do
        nkad = described_class.new(class_nm)
        expect(nkad.class_nm).to eq(class_nm)
        expect(nkad.curl_command).to include('tmp/download.zip')
        expect(nkad.curl_command).to include('-X GET')
        expect(nkad.curl_command).to include('https://nces.ed.gov/ipeds/datacenter/data/')
        expect(nkad.curl_command).to include('2023')
        expect(nkad.curl_command).not_to include('-d')
      end
    end

    it 'sets the curl command correctly for Hcm' do
      nkad = described_class.new('Hcm')
      expect(nkad.class_nm).to eq('Hcm')
      expect(nkad.curl_command).to include('tmp/hcm.xls')
      expect(nkad.curl_command)
        .to include('-H "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:125.0) Gecko/20100101 Firefox/125.0"')
      expect(nkad.curl_command).to include('https://studentaid.gov/sites/default/files/Schools-on-HCM-December-2024.xls')
      expect(nkad.curl_command).not_to include('-d')
    end
  end

  describe '#download_csv' do
    it 'calls Open3 to run the curl command and download the file' do
      nkad = described_class.new('Hcm')

      allow(Open3)
        .to receive(:capture3)
        .and_return(Open3.capture3('ls')) # how to mock Process::Status? Just run a simple command instead

      expect(nkad.download_csv).to be true
    end
  end

  # We obtain the download source for certain file types by scraping web page for most recent download link
  describe 'dynamic download sources' do
    describe '.fetch_ipeds_source_for' do
      %w[IpedsHd IpedsIc IpedsIcAy IpedsIcPy].each do |class_nm|
        it "iterates through html table and determines most recent download link for #{class_nm}" do
          matcher = described_class::IPEDS_MATCHERS[class_nm]
          link_tags = nokogiri_doc.css('.idc_gridviewrow td a').select { |link| link.text.match?(matcher) }
          expect(link_tags.size).to be > 1
          most_recent_link = described_class.send(:fetch_ipeds_source_for, class_nm)
          expect(most_recent_link).to include('2023')
        end
      end
    end
  end

  # Run this guy if you want to test the downloading making the remote calls. This can be done from the
  # command line as follows
  # EXTERNAL=true rspec spec/utilities/no_key_apis/no_key_api_downloader_spec.rb:line_number_of_describe
  # simplecov fails this because it's not part of the test suite proper. Turn that off
  # :nocov:
  describe '#download_csv using external call' do
    call_externally = ENV['EXTERNAL'].eql?('true') ? true : false
    context 'when making external calls', if: call_externally do
      it 'downloads the hcm file into the tmp folder' do
        system('rm tmp/hcm.xls') if File.exist?('tmp/hcm.xls')
        expect(File).not_to exist('tmp/hcm.xls')
        nkad = described_class.new('Hcm')
        nkad.download_csv
        expect(File).to exist('tmp/hcm.xls')
      end

      it 'downloads the eight key file into the tmp folder' do
        system('rm tmp/eight_key.xls') if File.exist?('tmp/eight_key.xls')
        expect(File).not_to exist('tmp/eight_key.xls')
        nkad = described_class.new('EightKey')
        nkad.download_csv
        expect(File).to exist('tmp/eight_key.xls')
      end

      %w[
        Accreditation AccreditationAction AccreditationInstituteCampus AccreditationRecord IpedsHd IpedsIc IpedsIcAy IpedsIcPy
      ].each do |class_nm|
        it "downloads the #{class_nm} into download.zip in the tmp folder" do
          system('rm tmp/download.zip') if File.exist?('tmp/download.zip')
          expect(File).not_to exist('tmp/download.zip')
          nkad = described_class.new(class_nm)
          nkad.download_csv
          expect(File).to exist('tmp/download.zip')
        end
      end
    end
  end
  # :nocov:
end

# frozen_string_literal: true

require 'rails_helper'

# These tests show the curl command is constructed properly, but the actual running is stubbed/mocked
# to avoid external dependencies and time to run issues. A suite has been added to test the remote
# calling, but it's advisable to run it from the command line separately and not as part of the test suite

RSpec.describe NoKeyApis::NoKeyApiDownloader do
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
        expect(nkad.curl_command).to include('https://nces.ed.gov/ipeds/datacenter/data')
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

  # Run this guy if you want to test the downloading making the remote calls. This can be done from the
  # command line as follows
  # EXTERNAL=true rspec spec/utilities/no_key_apis/no_key_api_downloader_spec.rb:line_number_of_describe
  # simplecov fails this because it's not part of the test suite proper. Turn that off
  # :nocov:
  describe '#download_csv using external call' do
    call_externally = ENV['EXTERNAL'].eql?('true') ? true : false
    context 'when making external calls', if: call_externally do
      it 'downloads the hcm file into the tmp folder' do
        system('rm tmp/hcm.xlsx') if File.exist?('tmp/hcm.xlsx')
        expect(File).not_to exist('tmp/hcm.xlsx')
        nkad = described_class.new('Hcm')
        nkad.download_csv
        expect(File).to exist('tmp/hcm.xlsx')
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

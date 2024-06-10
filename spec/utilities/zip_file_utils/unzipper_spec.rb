# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ZipFileUtils::Unzipper do
  describe '#initialize' do
    it 'sets the zip file name to what is passed in' do
      unzipper = described_class.new('tmp/downloaded.zip')
      expect(unzipper.zip_file_name).to eq('tmp/downloaded.zip')
    end

    it 'defaults the zip file name to tmp/download.zip when no name is provided' do
      unzipper = described_class.new
      expect(unzipper.zip_file_name).to eq('tmp/download.zip')
    end
  end

  describe '#unzip_the_file' do
    it 'returns true when successfully unzipping a file' do
      File.delete('tmp/download_hcm.zip') if File.exist?('tmp/download_hcm.zip')
      File.delete('tmp/hcm.csv') if File.exist?('tmp/hcm.csv')
      FileUtils.cp('spec/fixtures/download_hcm.zip', 'tmp')
      unzipper = described_class.new('tmp/download_hcm.zip')
      expect(unzipper.unzip_the_file).to be true
    end

    it 'returns false when unzipping fails' do
      system('rm tmp/download_hcm_corrupt.zip') if File.exist?('tmp/download_hcm_corrupt.zip')
      system('cp spec/fixtures/download_hcm_corrupt.zip tmp')
      unzipper = described_class.new('tmp/download_hcm_corrupt.zip')
      expect(unzipper.unzip_the_file).to be false
    end
  end
end

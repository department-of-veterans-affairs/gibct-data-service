# frozen_string_literal: true
require 'rails_helper'

RSpec.describe GibctSiteMapper, type: :model do
  subject { GibctSiteMapper.new(ping: false) }

  let(:preview_version) { Version.current_preview }
  let(:production_version) { Version.current_production }
  let(:sitemaps_path) { File.join(Rails.root, 'public', 'sitemap.xml.gz') }
  let(:preview_institution_fc) { '00000001' }
  let(:production_institution_fc) { '00000002' }

  before(:each) do
    File.delete(sitemaps_path) if File.exist?(sitemaps_path)

    [:preview, :production].each { |p| create :version, p }
    create :institution, version: preview_version.number, facility_code: preview_institution_fc
    create :institution, version: production_version.number, facility_code: production_institution_fc
  end

  describe 'when initializing' do
    it 'gets the latest production version' do
      SiteMapperHelper.silence do
        expect(subject.version).to eq(Version.current_production.number)
      end
    end

    it 'creates the sitemap' do
      SiteMapperHelper.silence do
        subject
      end

      sitemap = Zlib::GzipReader.open(sitemaps_path) do |gz|
        sitemap = gz.read
        expect(sitemap).to match(Regexp.new("/profile/#{production_institution_fc}"))
        expect(sitemap).not_to match(Regexp.new("/profile/#{preview_institution_fc}"))
      end
    end
  end
end

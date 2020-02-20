# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GibctSiteMapper, type: :model do
  let(:preview_version) { Version.current_preview }
  let(:production_version) { Version.current_production }
  let(:sitemaps_path) { Rails.root.join('public/sitemap.xml.gz') }
  let(:preview_institution_fc) { '00000001' }
  let(:production_institution_fc) { '00000002' }

  before do
    File.delete(sitemaps_path) if File.exist?(sitemaps_path)
    %i[production preview].each { |p| create :version, p }
    create :institution, version: preview_version.number, facility_code: preview_institution_fc
    create :institution, version: production_version.number, facility_code: production_institution_fc
  end

  describe 'when initializing' do
    it 'checks the site map URL' do
      SiteMapperHelper.silence do
        mapper = described_class.new(false)
        expect(mapper.sitemap_location).to eq('https://www.va.gov/gids/sitemap.xml.gz')
      end
    end

    it 'checks the default host URL' do
      SiteMapperHelper.silence do
        described_class.new(false)
        expect(SitemapGenerator::Sitemap.default_host).to eq('https://www.va.gov/gi-bill-comparison-tool')
      end
    end

    def create_sitemap_and_check_if_production
      SiteMapperHelper.silence do
        described_class.new(false)
      end
      Zlib::GzipReader.open(sitemaps_path) do |gz|
        sitemap = gz.read
        expect(sitemap).to match(Regexp.new("/profile/#{production_institution_fc}"))
        expect(sitemap).not_to match(Regexp.new("/profile/#{preview_institution_fc}"))
      end
    end

    it 'creates a sitemap with only production data' do
      create_sitemap_and_check_if_production
    end
  end
end

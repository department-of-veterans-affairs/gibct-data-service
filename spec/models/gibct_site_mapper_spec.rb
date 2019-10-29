# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GibctSiteMapper, type: :model do
  let(:preview_version) { Version.current_preview }
  let(:production_version) { Version.current_production }
  let(:sitemaps_path) { Rails.root.join('public', 'sitemap.xml.gz') }
  let(:preview_institution_fc) { '00000001' }
  let(:production_institution_fc) { '00000002' }

  before do
    File.delete(sitemaps_path) if File.exist?(sitemaps_path)

    %i[preview production].each { |p| create :version, p }
    create :institution, version: preview_version.number, facility_code: preview_institution_fc
    create :institution, version: production_version.number, facility_code: production_institution_fc

    # Stub out pinging in all cases
    allow_any_instance_of(described_class).to receive(:ping_search_engines)
  end

  describe 'when initializing' do
    it 'sets the default host and creates a sitemap with only production data' do
      [true, false].each do |ping|
        SiteMapperHelper.silence do
          mapper = described_class.new(ping)
          expect(mapper.sitemap_location).to eq('https://www.va.gov/gids/sitemap.xml.gz')
        end

        expect(SitemapGenerator::Sitemap.default_host).to eq('https://www.va.gov/gi-bill-comparison-tool')

        sitemap = Zlib::GzipReader.open(sitemaps_path) do |gz|
          sitemap = gz.read
          expect(sitemap).to match(Regexp.new("/profile/#{production_institution_fc}"))
          expect(sitemap).not_to match(Regexp.new("/profile/#{preview_institution_fc}"))
        end
      end
    end

    context 'when ping is false' do
      it 'does not ping the search engines' do
        expect_any_instance_of(described_class).not_to receive(:ping_search_engines)

        SiteMapperHelper.silence do
          described_class.new(false)
        end
      end
    end

    context 'when ping is true' do
      it 'pings the search engines' do
        expect_any_instance_of(described_class).to receive(:ping_search_engines)

        SiteMapperHelper.silence do
          described_class.new(true)
        end
      end
    end
  end
end

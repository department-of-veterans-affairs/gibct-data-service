# frozen_string_literal: true

# Creates sitemips for gi-bill-comparison-tool
class GibctSiteMapper
  DEFAULT_HOST = 'https://www.vets.gov/gi-bill-comparison-tool'

  def initialize(ping: true, default_host: DEFAULT_HOST, sitemaps_path: nil)
    SitemapGenerator::Sitemap.default_host = default_host || DEFAULT_HOST
    SitemapGenerator::Sitemap.sitemaps_path = sitemaps_path if sitemaps_path

    SitemapGenerator::Sitemap.create do
      add '/search', priority: 0.9, changefreq: 'monthly'

      Institution.find_each do |institution|
        add "/profile/#{institution.facility_code}", priority: 0.8, changefreq: 'weekly'
      end
    end

    ping_search_engines if ping
  end

  def ping_search_engines
    SitemapGenerator::Sitemap.ping_search_engines
  end
end

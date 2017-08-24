# frozen_string_literal: true

# Creates sitemips for gi-bill-comparison-tool
class GibctSiteMapper
  DEFAULT_HOST = 'https://www.vets.gov/gi-bill-comparison-tool'

  def initialize(ping: true, default_host: DEFAULT_HOST, sitemaps_path: nil, verbose: true)
    return if version.blank?

    configure_sitemap(default_host, sitemaps_path, verbose)
    generate_sitemap(version)

    ping_search_engines if ping && version.present?
  end

  def version
    @version ||= Version.current_production&.number
  end

  protected

  def configure_sitemap(host, path, verbose)
    SitemapGenerator::Sitemap.default_host = host || DEFAULT_HOST
    SitemapGenerator::Sitemap.sitemaps_path = path if path
    SitemapGenerator.verbose = verbose
  end

  def generate_sitemap(v)
    SitemapGenerator::Sitemap.create do
      add '/search', priority: 0.9, changefreq: 'monthly'

      Institution.version(v).find_each do |institution|
        add "/profile/#{institution.facility_code}", priority: 0.8, changefreq: 'weekly'
      end
    end
  end

  def ping_search_engines
    SitemapGenerator::Sitemap.ping_search_engines if version.present?
  end
end

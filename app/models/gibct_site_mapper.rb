# frozen_string_literal: true

# Creates sitemips for gi-bill-comparison-tool
class GibctSiteMapper
  PRODUCTION_HOST = 'www.va.gov'

  def initialize(ping, verbose = true)
    return if version.blank?

    configure_sitemap(verbose)
    generate_sitemap(version)

    ping_search_engines if ping && version.present?
  end

  def version
    @version ||= Version.current_production&.id
  end

  def sitemap_location
    "https://#{PRODUCTION_HOST}/gids/sitemap.xml.gz"
  end

  protected

  def configure_sitemap(verbose)
    SitemapGenerator::Sitemap.default_host = "https://#{PRODUCTION_HOST}/gi-bill-comparison-tool"
    SitemapGenerator.verbose = verbose
  end

  def generate_sitemap(version)
    SitemapGenerator::Sitemap.create do
      add '/search', priority: 0.9, changefreq: 'monthly'

      Institution.where(version_id: version)
                 .find_each(batch_size: Settings.active_record.batch_size.find_each) do |institution|
        add "/profile/#{institution.facility_code}", priority: 0.8, changefreq: 'weekly'
      end
    end
  end

  def ping_search_engines
    SitemapGenerator::Sitemap.ping_search_engines(sitemap_location) if version.present?
  end
end

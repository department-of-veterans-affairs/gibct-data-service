# frozen_string_literal: true

module NoKeyApis
  class DynamicDownloadSource
    attr_reader :href

    def initialize(url)
      raise NotImplementedError, 'abstract class cannot be initialized' if instance_of?(DynamicDownloadSource)

      @url = url
      @html = scrape_html
      @href = parse_html
    end

    def self.fetch(*args)
      new(*args).href
    end

    private

    def cache_html?
      cache_key.present?
    end

    # subclass must define CACHE_KEY constant to enable caching
    def cache_key
      return nil unless self.class.const_defined?(:CACHE_KEY)

      self.class::CACHE_KEY
    end

    def parse_html
      raise NotImplementedError, '#parse_refs must be defined in subclass'
    end

    def scrape_html
      page = do_cached_with { HTTParty.get(@url).body }
      Nokogiri::HTML(page)
    rescue StandardError => e
      Rails.logger.error("Error scraping #{@url}: #{e.message}")
      nil
    end

    # cache html via solid cache if caching enabled in subclass
    def do_cached_with(&block)
      return yield unless cache_html?

      Rails.cache.fetch(cache_key, expires_in: 1.hour, &block)
    end
  end
end

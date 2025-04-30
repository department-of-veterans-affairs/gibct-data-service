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

    def parse_html
      raise NotImplementedError, '#parse_refs must be defined in subclass'
    end

    def scrape_html
      page = Rails.cache.fetch(@url, expires_in: 1.hour) do
        HTTParty.get(@url).body
      end
      Nokogiri::HTML(page)
    rescue StandardError => e
      Rails.logger.error("Error scraping #{@url}: #{e.message}")
      nil
    end
  end
end

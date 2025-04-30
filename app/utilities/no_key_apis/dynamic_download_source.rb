# frozen_string_literal: true

module NoKeyApis
  class DynamicDownloadSource
 
    def initialize(url)
      if self.class == DynamicDownloadSource
        raise NotImplementedError, 'abstract class cannot be initialized'
      end

      @url = url
      @html = scrape_html
      @href = parse_html
    end

    def fetch(*args)
      self.new(*args).href
    end

    private
  
    def parse_hrefs
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

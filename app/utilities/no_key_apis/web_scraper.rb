# frozen_string_literal: true

module NoKeyApis
  class WebScraper
    attr_reader :url

    def initialize(url)
      @url = url
    end

    # Returns Nokogiri::HTML document
    # HTTParty gem handles redirects (to-do: update Faraday in order to use faraday-follow_redirects gem)
    def scrape
      page = HTTParty.get(@url).body
      Nokogiri::HTML(page)
    rescue StandardError => e
      Rails.logger.error e
    end
  end
end

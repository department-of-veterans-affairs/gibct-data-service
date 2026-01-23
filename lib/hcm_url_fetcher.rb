# frozen_string_literal: true

module HcmUrlFetcher
  HCM_JSON_URL = 'https://studentaid.gov/data-center/school/hcm.json'
  BASE_URL = 'https://studentaid.gov'
  DEFAULT_URL = 'https://studentaid.gov/sites/default/files/Schools-on-HCM-December-2024.xls'

  def self.fetch_latest_url
    conn = Faraday.new { |f| f.headers['User-Agent'] = 'Mozilla/5.0' }

    Rails.logger.info "Fetching HCM URL from #{HCM_JSON_URL}"
    response = conn.get(HCM_JSON_URL)
    unless response.success?
      Rails.logger.error "Failed to fetch HCM URL: #{response.status} - #{response.reason_phrase}"
      return DEFAULT_URL
    end

    json = JSON.parse(response.body)
    href = json.dig('mainContent', 6, 'data', 0, 'data', 0, 'href')
    if href.nil?
      Rails.logger.error "Failed to find HCM URL parsing: #{json}"
      return DEFAULT_URL
    end

    href.start_with?('http') ? href : "#{BASE_URL}#{href}"
  rescue StandardError => e
    Rails.logger.error "Failed to fetch HCM URL: #{e.message}"
    DEFAULT_URL
  end
end

# frozen_string_literal: true

module NoKeyApis
  class IpedsDownloadSource < DynamicDownloadSource
    IPEDS_URL = 'https://nces.ed.gov/ipeds/datacenter'
    IPEDS_DOWNLOADS_PATH = 'DataFiles.aspx?year=-1'
    IPEDS_MATCHERS = {
      'IpedsHd' => /^HD\d{4}$/,
      'IpedsIc' => /^IC\d{4}$/,
      'IpedsIcAy' => /^IC\d{4}_AY$/,
      'IpedsIcPy' => /^IC\d{4}_PY$/
    }.freeze

    def initialize(ipeds_type)
      @type = ipeds_type
      super("#{IPEDS_URL}/#{IPEDS_DOWNLOADS_PATH}")
    end

    private

    def parse_html
      link_tag = @html&.css('.idc_gridviewrow td a')
                       .find { |link| link.text.match?(IPEDS_MATCHER[@type]) }
      "#{IPEDS_URL}/#{link_tag['href']}" if link_tag
    end
  end
end

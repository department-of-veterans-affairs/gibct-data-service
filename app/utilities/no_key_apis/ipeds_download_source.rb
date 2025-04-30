# frozen_string_literal: true

module NoKeyApis
  class IpedsDownloadSource < DynamicDownloadSource
    URL = 'https://nces.ed.gov/ipeds/datacenter'
    DOWNLOADS_PATH = 'DataFiles.aspx?year=-1'
    MATCHERS = {
      'IpedsHd' => /^HD\d{4}$/,
      'IpedsIc' => /^IC\d{4}$/,
      'IpedsIcAy' => /^IC\d{4}_AY$/,
      'IpedsIcPy' => /^IC\d{4}_PY$/
    }.freeze
    CACHE_KEY = 'ipeds_html'

    def initialize(ipeds_type)
      @type = ipeds_type
      super("#{URL}/#{DOWNLOADS_PATH}")
    end

    private

    def cache_html?
      true
    end

    def parse_html
      return unless @html

      link_tag = @html.css('.idc_gridviewrow td a')
                      .find { |link| link.text.match?(MATCHERS[@type]) }
      "#{URL}/#{link_tag['href']}" if link_tag
    end
  end
end

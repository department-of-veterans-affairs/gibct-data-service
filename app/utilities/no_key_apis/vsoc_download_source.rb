# frozen_string_literal: true

module NoKeyApis
  class VsocDownloadSource < DynamicDownloadSource
    URL = 'https://vbaw.vba.va.gov/education/job_aids.asp'

    CACHE_KEY = 'vsoc_html'

    def initialize
      super(URL)
    end

    private

    def parse_html
      return unless @html

      href = @html.css('a').map{|a| a['href']}.find{|str| str =~ /vsoc.*\.csv\Z/i}
      unless href
        Rails.logger.warn("NoKeyApiDownloader: Failed to find VSOC link on page")
        return ''
      end

      # hrefs can be relative (/foo/bar) or absolute (https://example.com/foo/bar)
      # let's handle both cases
      href.starts_with?('/') ? "https://vbaw.vba.va.gov#{href}" : href
    end
  end
end


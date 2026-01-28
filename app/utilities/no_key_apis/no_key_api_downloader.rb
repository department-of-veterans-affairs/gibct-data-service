# frozen_string_literal: true

module  NoKeyApis
  class NoKeyApiDownloader
    API_DOWNLOAD_CONVERSION_NAMES = {
      'AccreditationInstituteCampus' => 'tmp/InstitutionCampus.csv',
      'Hcm' => 'tmp/hcm.xls',
      'IpedsHd' => 'tmp/ipeds_hd.csv',
      'IpedsIc' => 'tmp/ipeds_ic.csv',
      'IpedsIcAy' => 'tmp/ipeds_ic_ay.csv',
      'IpedsIcPy' => 'tmp/ipeds_ic_py.csv',
      'Mou' => 'tmp/mou.xlsx',
      'Vsoc' => 'tmp/vsoc.csv'
    }.freeze

    # Vsoc uses -k parameter to bypass SSL certificate errors
    API_NO_KEY_DOWNLOAD_SOURCES = {
      'Accreditation' => [' -X POST', 'https://ope.ed.gov/dapip/api/downloadFiles/accreditationDataFiles'],
      'AccreditationAction' => [' -X POST', 'https://ope.ed.gov/dapip/api/downloadFiles/accreditationDataFiles'],
      'AccreditationInstituteCampus' => [' -X POST', 'https://ope.ed.gov/dapip/api/downloadFiles/accreditationDataFiles'],
      'AccreditationRecord' => [' -X POST', 'https://ope.ed.gov/dapip/api/downloadFiles/accreditationDataFiles'],
      'EightKey' => [' -X GET', 'https://www.ed.gov/sites/ed/files/documents/military/8-keys-sites.xls'],
      'Hcm' => ['', -> { HcmUrlFetcher.fetch_latest_url }],
      'IpedsHd' => [' -X GET', -> { IpedsDownloadSource.fetch('IpedsHd') }],
      'IpedsIc' => [' -X GET', -> { IpedsDownloadSource.fetch('IpedsIc') }],
      'IpedsIcAy' => [' -X GET', -> { IpedsDownloadSource.fetch('IpedsIcAy') }],
      'IpedsIcPy' => [' -X GET', -> { IpedsDownloadSource.fetch('IpedsIcPy') }],
      'Mou' => [' -X POST', 'https://dhra.appianportalsgov.com/DoD-MOU/record/dataexport/download-grid'],
      'Vsoc' => [' -k -X GET', -> { VsocDownloadSource.fetch }]
    }.freeze

    attr_accessor :class_nm, :curl_command, :url

    def initialize(class_nm)
      @class_nm = class_nm
      rest_command, source = API_NO_KEY_DOWNLOAD_SOURCES[@class_nm]
      @url = url_from(source)
      Rails.logger.info("\n\n\n***Curl command: #{rest_command} #{url} #{h_parm} #{o_parm} #{d_parm} ***\n\n\n")
      @curl_command = "curl#{rest_command} #{url} #{h_parm} #{o_parm} #{d_parm}"
    end

    def download_csv
      _stdout, _stderr, status = Open3.capture3(@curl_command)

      status.success?
    end

    private

    def h_parm
      # Vsoc uses the octet-stream header to pull down from source
      return '-H "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:125.0) Gecko/20100101 Firefox/125.0"' if @class_nm.eql?('Hcm')
      return '-H \'Content-Type: application/octet-stream\'' if @class_nm.eql?('Vsoc')

      if @class_nm.eql?('Mou')
        str = '-H \'accept: text/html,application/xhtml+xml,application/xml\''
        str += ' -H \'content-type: application/x-www-form-urlencoded\''
        return str
      end

      '-H \'Content-Type: application/json\''
    end

    def o_parm
      case @class_nm
      # hcm has been tricky because it gets updated periodically and the extension changes.
      # The information is hidden behind some javascripting, so the html cannot easily be scraped.
      # an api was discovered that can bring back the list of available files and the most
      # recent file is always the first as of this refactor
      when 'Hcm'
        ext = @url.end_with?('.xlsx') ? 'xlsx' : 'xls'
        "-o tmp/hcm.#{ext}"
      when 'EightKey' then '-o tmp/eight_key.xls'
      when 'Mou' then '-o tmp/mou.xlsx'
      when 'Vsoc' then '-o tmp/vsoc.csv'
      else '-o tmp/download.zip'
      end
    end

    def d_parm
      if @class_nm.start_with?('Accreditation')
        "-d '{\"CSVChecked\":true,\"ExcelChecked\":false}'"
      elsif @class_nm == 'Mou'
        # this crazy param was copied directly from the browser dev tools, and does seem necessary to get the API call to work
        "--data-raw #{File.read(data_param_path('mou_raw_data'))}"
      else
        ''
      end
    end

    # If download source is a proc (and not url string), call proc to dynamically fetch url
    def url_from(source)
      return source unless source.is_a?(Proc)

      source.call
    end

    def data_param_path(name)
      Rails.root.join('app', 'utilities', 'no_key_apis', 'curl_params', name)
    end
  end
end

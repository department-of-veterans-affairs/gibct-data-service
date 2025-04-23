# frozen_string_literal: true

module  NoKeyApis
  class NoKeyApiDownloader
    # the most recent IPED data files are from 2022. This should be checked periodically.
    # the most recent Hcm data files are from 2020.  This should be checked periodically.
    # changes will need to be made to both hashes when these change

    # HCM has changed to xls from xlsx. Every quarter the file is updated and this needs to be checked
    # as part of that. API_DOWNLOAD_CONVERSION_NAMES, API_NO_KEY_DOWNLOAD_SOURCES and o_parm need to be
    # changed accordingly. This will also affect the dashboards_controller upload_files method

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
      'Hcm' => ['', 'https://studentaid.gov/sites/default/files/Schools-on-HCM-December-2024.xls'],
      'IpedsHd' => [' -X GET', -> { fetch_ipeds_source_for('IpedsHd') }],
      'IpedsIc' => [' -X GET', -> { fetch_ipeds_source_for('IpedsIc') }],
      'IpedsIcAy' => [' -X GET', -> { fetch_ipeds_source_for('IpedsIcAy') }],
      'IpedsIcPy' => [' -X GET', -> { fetch_ipeds_source_for('IpedsIcPy') }],
      'Mou' => [' -X GET', "'https://www.dodmou.com/Home/DownloadS3File?s3bucket=dodmou-private-ah9xbf&s3Key=participatinginstitutionslist%2Fproduction%2FInstitutionsList.xlsx'"],
      'Vsoc' => [' -k -X GET', -> { fetch_vsoc_source } ]
    }.freeze

    IPEDS_URL = 'https://nces.ed.gov/ipeds/datacenter'
    IPEDS_DOWNLOADS_PATH = 'DataFiles.aspx?year=-1'
    IPEDS_MATCHERS = {
      'IpedsHd' => /^HD\d{4}$/,
      'IpedsIc' => /^IC\d{4}$/,
      'IpedsIcAy' => /^IC\d{4}_AY$/,
      'IpedsIcPy' => /^IC\d{4}_PY$/
    }.freeze

    VSOC_INDEX_URL = 'https://vbaw.vba.va.gov/education/job_aids.asp'

    attr_accessor :class_nm, :curl_command, :url

    def initialize(class_nm)
      @class_nm = class_nm
      rest_command, url_or_proc = API_NO_KEY_DOWNLOAD_SOURCES[@class_nm]
      # Certain url values exist as procs which dynamically fetch latest download source urls
      url = url_or_proc.try(:call) || url_or_proc
      @curl_command = "curl#{rest_command} #{url} #{h_parm} #{o_parm}#{d_parm}"
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

      '-H \'Content-Type: application/json\''
    end

    def o_parm
      case @class_nm
      when 'Hcm' then '-o tmp/hcm.xls'
      when 'EightKey' then '-o tmp/eight_key.xls'
      when 'Mou' then '-o tmp/mou.xlsx'
      when 'Vsoc' then '-o tmp/vsoc.csv'
      else '-o tmp/download.zip'
      end
    end

    def d_parm
      return '' unless @class_nm.start_with?('Accreditation')

      " -d '{\"CSVChecked\":true,\"ExcelChecked\":false}'"
    end

    def self.fetch_ipeds_source_for(class_nm)
      # Nokogiri HTML document
      doc = NoKeyApis::WebScraper.new("#{IPEDS_URL}/#{IPEDS_DOWNLOADS_PATH}").scrape
      link_tag = doc.css('.idc_gridviewrow td a')
                    .select { |link| link.text.match?(IPEDS_MATCHERS[class_nm]) }
                    .first
      "#{IPEDS_URL}/#{link_tag['href']}"
    end
    private_class_method :fetch_ipeds_source_for
  end
end

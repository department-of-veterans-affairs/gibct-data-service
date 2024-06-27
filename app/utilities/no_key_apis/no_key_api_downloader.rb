# frozen_string_literal: true

module  NoKeyApis
  class NoKeyApiDownloader
    # the most recent IPED data files are from 2022. This should be checked periodically.
    # the most recent Hcm data files are from 2020.  This should be checked periodically.
    # changes will need to be made to both hashes when these change
    API_DOWNLOAD_CONVERSION_NAMES = {
      'AccreditationInstituteCampus' => 'tmp/InstitutionCampus.csv',
      'Hcm' => 'tmp/hcm.xlsx',
      'IpedsHd' => 'tmp/hd2022.csv',
      'IpedsIcAy' => 'tmp/ic2022_ay.csv',
      'IpedsIcPy' => 'tmp/ic2022_py.csv',
      'IpedsIc' => 'tmp/ic2022.csv',
      'Mou' => 'tmp/mou.xlsx'
    }.freeze

    API_NO_KEY_DOWNLOAD_SOURCES = {
      'Accreditation' => [' -X POST', 'https://ope.ed.gov/dapip/api/downloadFiles/accreditationDataFiles'],
      'AccreditationAction' => [' -X POST', 'https://ope.ed.gov/dapip/api/downloadFiles/accreditationDataFiles'],
      'AccreditationInstituteCampus' => [' -X POST', 'https://ope.ed.gov/dapip/api/downloadFiles/accreditationDataFiles'],
      'AccreditationRecord' => [' -X POST', 'https://ope.ed.gov/dapip/api/downloadFiles/accreditationDataFiles'],
      'EightKey' => [' -X GET', 'https://www2.ed.gov/documents/military/8-keys-sites.xls'],
      'Hcm' => ['', 'https://studentaid.gov/sites/default/files/Schools-on-HCM-December2023.xlsx'],
      'IpedsHd' => [' -X GET', 'https://nces.ed.gov/ipeds/datacenter/data/HD2022.zip'],
      'IpedsIc' => [' -X GET', 'https://nces.ed.gov/ipeds/datacenter/data/IC2022.zip'],
      'IpedsIcAy' => [' -X GET', 'https://nces.ed.gov/ipeds/datacenter/data/IC2022_AY.zip'],
      'IpedsIcPy' => [' -X GET', 'https://nces.ed.gov/ipeds/datacenter/data/IC2022_PY.zip'],
      'Mou' => [' -X GET', "'https://www.dodmou.com/Home/DownloadS3File?s3bucket=dodmou-private-ah9xbf&s3Key=participatinginstitutionslist%2Fproduction%2FInstitutionsList.xlsx'"]
    }.freeze

    attr_accessor :class_nm, :curl_command

    def initialize(class_nm)
      @class_nm = class_nm
      rest_command, url = API_NO_KEY_DOWNLOAD_SOURCES[@class_nm]
      @curl_command = "curl#{rest_command} #{url} #{h_parm} #{o_parm}#{d_parm}"
    end

    def download_csv
      _stdout, _stderr, status = Open3.capture3(@curl_command)

      status.success?
    end

    private

    def h_parm
      return '-H "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:125.0) Gecko/20100101 Firefox/125.0"' if @class_nm.eql?('Hcm')

      '-H \'Content-Type: application/json\''
    end

    def o_parm
      case @class_nm
      when 'Hcm' then '-o tmp/hcm.xlsx'
      when 'EightKey' then '-o tmp/eight_key.xls'
      when 'Mou' then '-o tmp/mou.xlsx'
      else '-o tmp/download.zip'
      end
    end

    def d_parm
      return '' unless @class_nm.start_with?('Accreditation')

      " -d '{\"CSVChecked\":true,\"ExcelChecked\":false}'"
    end
  end
end

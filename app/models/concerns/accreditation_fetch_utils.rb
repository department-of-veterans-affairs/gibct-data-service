# frozen_string_literal: true

module AccreditationFetchUtils
  extend ActiveSupport::Concern

  class_methods do
    def download_accreditation_csv
      _stdout, _stderr, status = Open3.capture3("curl -X POST \
        https://ope.ed.gov/dapip/api/downloadFiles/accreditationDataFiles \
        -H 'Content-Type: application/json' -d '{\"CSVChecked\":true,\"ExcelChecked\":false}' -o tmp/download.zip")
      status.success?
    end

    def unzip_csv
      begin
        Zip::File.open('tmp/download.zip') do |zip_file|
          zip_file.each do |f|
            f_path = File.join('tmp', f.name)
            FileUtils.mkdir_p(File.dirname(f_path))
            File.delete(f_path) if File.exist?(f_path)
            zip_file.extract(f, f_path)
          end
        end
      rescue StandardError => _e
        return false
      end
      true
    end
  end
end

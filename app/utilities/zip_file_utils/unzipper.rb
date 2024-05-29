# frozen_string_literal: true

module  ZipFileUtils
  class Unzipper
    attr_accessor :zip_file_name

    # default to tmp/download.zip if nothing's passed in
    def initialize(zip_file_name = 'tmp/download.zip')
      @zip_file_name = zip_file_name
    end

    def unzip_the_file
      Zip::File.open(@zip_file_name) do |zip_file|
        zip_file.each do |f|
          f_path = File.join('tmp', f.name)
          FileUtils.mkdir_p(File.dirname(f_path)) unless File.exist?(File.dirname(f_path))
          File.delete(f_path) if File.exist?(f_path)
          zip_file.extract(f, f_path)
        end
      end
      true
    rescue StandardError => _e
      false
    end
  end
end

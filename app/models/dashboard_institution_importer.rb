# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class DashboardInstitutionImporter
  # :nocov:
  include DashboardWatir

  INSTITUTION_FILES = {
    0 => 'InstitutionVersion_1', 1 => 'InstitutionVersion_2', 2 => 'InstitutionVersion_3',
    3 => 'InstitutionVersion_4', 4 => 'InstitutionVersion_5', 5 => 'InstitutionVersion_6',
    6 => 'InstitutionVersion_7', 7 => 'InstitutionVersion_8', 8 => 'InstitutionVersion_9',
    9 => 'InstitutionVersion_10'
  }.freeze

  attr_accessor :upload_version, :upload_version_id

  def initialize(user, pass, load_env = nil)
    common_initialize_watir(user, pass, load_env)
    @workfiles = Array.new(INSTITUTION_FILES.size)
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Lint/RescueException
  def upload_institution_csv_file
    login_to_dashboard

    set_upload_version_id

    log_and_puts('     Uploading CSV file for Institution.')

    INSTITUTION_FILES.each_value { |file_name| remove_existing_csv_file_for(file_name) }

    split_institutions_file

    INSTITUTION_FILES.each_value do |file_name|
      log_and_puts("       Starting processing for #{file_name}")
      multiple_file_upload = (file_name.include?('Institution1') ? false : true)
      begin
        upload_with_parameters('Institution', file_name, multiple_file_upload)
      rescue Exception => e
        log_and_puts("       Error trying to upload #{file_name}: #{e.message}...")
        log_and_puts('       Trying again in 10 seconds...')
        sleep(10)
        log_out_and_back_in(file_name)
        # If it fails on uploading the last file, you have to explicitly log back in.
        # the log_out_and_back_in method skips logging in on the last file.
        login_to_dashboard if file_name.eql?(INSTITUTION_FILES.values.last)
        begin
          upload_with_parameters('Institution', file_name, multiple_file_upload)
        rescue Exception => e
          log_and_puts("       Failed again #{e.message}...")
          return 1
        end
      end
      log_and_puts("       Done processing for #{file_name}")
      log_out_and_back_in(file_name)
    end

    0
  end
  # rubocop:enable Lint/RescueException
  # rubocop:enable Metrics/MethodLength

  private

  def set_logger
    logger_time = Time.now.getlocal.strftime('%Y%m%d_%H%M%S')
    log_file_name = Rails.root.join('log', "import_institution_#{logger_time}.log")
    @eilogger = Logger.new(log_file_name)
    log_and_puts("***** Starting import_institution_#{logger_time} *****")

    # open a terminal and tail the log in it
    `gnome-terminal --title="Tail log #{logger_time}" -- bash -c "tail -f #{log_file_name}; exec bash -i"`
  end

  def set_upload_version_id
    @upload_version = @bsess.td(id: 'current-production-version').text.to_i
    @upload_version_id = @bsess.hidden(id: 'VersionId').value.to_i
  end

  def remove_existing_csv_file_for(table_name)
    log_and_puts("  Removing existing CSV file for #{table_name}")

    return unless File.exist?("#{@download_dir}/#{table_name}.csv")

    File.delete("#{@download_dir}/#{table_name}.csv")
  end

  def upload_with_parameters(table_name, file_name, multiple_file_upload = false)
    log_and_puts("         Uploading #{file_name}")
    button = @bsess.link(role: 'button', href: "#{@import_prefix}#{table_name}", visible_text: 'Upload')
    button.click

    @bsess.text_field(id: 'upload_skip_lines').set(0)
    @bsess.file_field(id: 'upload_upload_file').set("#{@download_dir}/#{file_name}.csv")

    @bsess
      .text_field(id: 'upload_comment')
      .set("Uploaded on #{Time.now.getlocal} from Production export")

    @bsess.checkbox(id: 'upload_multiple_file_upload').check if multiple_file_upload
    @bsess.form(id: 'new_upload').submit

    if @bsess.link(text: 'View Dashboard').present?
      log_and_puts("         Successfully uploaded #{file_name}")
      @bsess.link(text: 'View Dashboard').click
    else # retry once
      log_and_puts('    Could not find the dashboard link - most likely it failed')
      sleep(30)
      @bsess.goto(@dashboard_url)
      raise Net::ReadTimeout
    end
  end

  # Institution has approx 75k lines, split into n files so that we don't run out of memory in Development/Staging
  def split_institutions_file
    INSTITUTION_FILES.each_key do |file_number|
      @workfiles[file_number] = File.open("#{@download_dir}/InstitutionVersion_#{file_number + 1}.csv", 'w')
    end

    # The insitutions download file has the version number in tha name right before the extension
    # If more than one got downloaded, use the one with the highest number. Note this breaks on
    # 999 -> 1000 or 9999 -> 10000 ...
    file = Dir.glob("#{download_dir}/institutions_version*.csv").last
    lines_per_subfile = calculate_lines_per_subfile(file)

    File.open(file).each_with_index do |row, index|
      if index.zero? # write the header row to each workfile
        @workfiles.each_index { |idx| @workfiles[idx].write(row) }
      else
        row_array = row.split(',')
        row_array[0] = @upload_version
        row_array[117] = @upload_version_id

        @workfiles[index.div(lines_per_subfile)].write(row_array.join(','))
      end
    end

    @workfiles.each { |f| f.close }
  end

  def calculate_lines_per_subfile(file)
    linecount = File.foreach(file).count
    # It's necessary to add some lines to the total count to account for the header row in each file
    # Not doing this causes an array out of bounds error when trying to write to the last file
    (linecount + INSTITUTION_FILES.size).div(INSTITUTION_FILES.size)
  end

  def log_out_and_back_in(file_name)
    log_and_puts('*** Logging out')
    @bsess.link(text: 'Log Out').click if @bsess.link(text: 'Log Out').present?
    @bsess = nil # close the browser session to free up memory
    log_and_puts ''
    sleep(5)

    # last file to upload - no need to log back in
    if file_name.eql?(INSTITUTION_FILES.values.last)
      log_and_puts('*** Finished uploading tables ***')
    else
      login_to_dashboard
    end
  end
  # :nocov:
end
# rubocop:enable Metrics/ClassLength

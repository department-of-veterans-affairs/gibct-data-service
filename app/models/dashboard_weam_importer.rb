# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class DashboardWeamImporter
  # :nocov:
  include DashboardWatir

  WEAM_FILES = {
    0 => 'Weam1', 1 => 'Weam2', 2 => 'Weam3', 3 => 'Weam4', 4 => 'Weam5', 5 => 'Weam6', 6 => 'Weam7'
  }.freeze

  def initialize(user, pass, load_env = nil)
    common_initialize_watir(user, pass, load_env)
    @workfiles = Array.new(WEAM_FILES.size)
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Lint/RescueException
  def upload_weam_csv_file
    login_to_dashboard

    log_and_puts('     Uploading CSV file for Weam.')

    WEAM_FILES.each_value { |weam_file_name| remove_existing_csv_file_for(weam_file_name) }

    split_weams_file

    WEAM_FILES.each_value do |weam_file_name|
      log_and_puts("       Starting processing for #{weam_file_name}")
      multiple_file_upload = (weam_file_name.include?('Weam1') ? false : true)
      begin
        upload_with_parameters('Weam', weam_file_name, multiple_file_upload)
      rescue Exception => e
        log_and_puts("       Error trying to upload #{weam_file_name}: #{e.message}...")
        log_and_puts('       Trying again in 10 seconds...')
        sleep(10)
        log_out_and_back_in(weam_file_name)
        # If it fails on uploading the last file, you have to explicitly log back in.
        # the log_out_and_back_in method skips logging in on the last file.
        login_to_dashboard if file_name.eql?(WEAM_FILES.values.last)
        begin
          upload_with_parameters('Weam', weam_file_name, multiple_file_upload)
        rescue Exception => e
          log_and_puts("       Failed again #{e.message}...")
          return 1
        end
      end
      log_and_puts("       Done processing for #{weam_file_name}")
      log_out_and_back_in(weam_file_name)
    end

    0
  end
  # rubocop:enable Lint/RescueException
  # rubocop:enable Metrics/MethodLength

  private

  def set_logger
    logger_time = Time.now.getlocal.strftime('%Y%m%d_%H%M%S')
    log_file_name = Rails.root.join('log', "import_weam_#{logger_time}.log")
    @eilogger = Logger.new(log_file_name)
    log_and_puts("***** Starting import_weam_#{logger_time} *****")

    # open a terminal and tail the log in it
    `gnome-terminal --title="Tail log #{logger_time}" -- bash -c "tail -f #{log_file_name}; exec bash -i"`
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

  # Weam has approx 75k lines, split into n files so that we don't run out of memory in Staging
  def split_weams_file
    WEAM_FILES.each_key do |file_number|
      @workfiles[file_number] = File.open("#{@download_dir}/Weam#{file_number + 1}.csv", 'w')
    end

    lines_per_subfile = calculate_lines_per_subfile

    File.open("#{@download_dir}/Weam.csv").each_with_index do |row, index|
      if index.zero? # write the header row to each workfile
        @workfiles.each_index { |idx| @workfiles[idx].write(row) }
      else
        @workfiles[index.div(lines_per_subfile)].write(row)
      end
    end

    # rubocop:disable Style/SymbolProc
    @workfiles.each { |file| file.close }
    # rubocop:enable Style/SymbolProc
  end

  def calculate_lines_per_subfile
    linecount = `wc -l < #{@download_dir}/Weam.csv`.to_i
    # It's necessary to add some lines to the total count to account for the header row in each file
    # Not doing this causes an array out of bounds error when trying to write to the last file
    (linecount + WEAM_FILES.size).div(WEAM_FILES.size)
  end

  def log_out_and_back_in(file_name)
    log_and_puts('*** Logging out')
    @bsess.link(text: 'Log Out').click if @bsess.link(text: 'Log Out').present?
    @bsess = nil # close the browser session to free up memory
    log_and_puts ''
    sleep(5)

    # last file to upload - no need to log back in
    if file_name.eql?(WEAM_FILES.values.last)
      log_and_puts('*** Finished uploading tables ***')
    else
      login_to_dashboard
    end
  end
  # :nocov:
end
# rubocop:enable Metrics/ClassLength

# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class DashboardExporterImporter
  # :nocov:
  LOCAL_URL = 'http://localhost:4000/user/sign_in'
  LOCAL_DASHBOARD = 'http://localhost:4000/dashboards'
  LOCAL_IMPORT_PREFIX = '/uploads/new/'

  PROD_URL = 'https://www.va.gov/gids/user/sign_in'
  EXPORT_PREFIX = '/gids/dashboards/export/'

  STAGE_URL = 'https://staging.va.gov/gids/user/sign_in'
  STAGE_DASHBOARD = 'https://staging.va.gov/gids/dashboards'
  STAGE_IMPORT_PREFIX = '/gids/uploads/new/'

  TIMEOUT = 600 # seconds

  attr_accessor :headless, :bsess, :download_dir, :login_url, :dashboard_url, :import_prefix, :user, :pass, :eilogger

  def initialize(user, pass, load_env = nil)
    @user = user
    @pass = pass

    set_logger
    set_url_variables_for_job(load_env)

    @download_dir = set_download_dir
    @headless = Headless.new
    @headless.start

    login_to_dashboard
  end

  def download_all_table_data
    CSV_TYPES_ALL_TABLES_CLASSES.each do |table_class|
      table_name = table_class.to_s

      next if table_name.eql?('InstitutionSchoolRating') # The table is not active yet

      remove_existing_csv_file_for(table_name)
      download_csv_file_for(table_name)
    end

    0
  end

  # rubocop:disable Lint/RescueException
  def upload_all_table_data
    CSV_TYPES_ALL_TABLES_CLASSES.each do |table_class|
      table_name = table_class.to_s

      # The table is not active yet
      next if table_name.eql?('InstitutionSchoolRating')
      # This table has CORS issues loading to the staging server
      next if table_name.eql?('CipCode') && @login_url.eql?(STAGE_URL)
      # Weam  has it's own routine for uploading
      next if table_name.eql?('Weam')

      begin
        upload_csv_file_for(table_name)
      rescue Exception => e
        log_and_puts("       Error: #{e.message}...")
        retry_upload_for(table_name)
      end
    end

    0
  end

  def retry_upload_for(table_name)
    sleep(10)
    begin
      log_out_and_back_in(table_name)
      upload_csv_file_for(table_name)
    rescue Exception => e
      log_and_puts("       Failed again, #{e.message}, skipping...")
    end
  end
  # rubocop:enable Lint/RescueException

  def finalize
    @headless.destroy
    log_and_puts('*** All done! You can close this terminal window. ***')
  end

  private

  def set_logger
    logger_time = Time.now.getlocal.strftime('%Y%m%d_%H%M%S')
    log_file_name = Rails.root.join('log', "export_import_#{logger_time}.log")
    @eilogger = Logger.new(log_file_name)
    log_and_puts("***** Starting export_import_#{logger_time} *****")

    # open a terminal and tail the log in it
    `gnome-terminal --title="Tail log #{logger_time}" -- bash -c "tail -f #{log_file_name}; exec bash -i"`
  end

  # load_env is target enviroment for upload/download
  def set_url_variables_for_job(load_env)
    case load_env
    when 'l', 'local', 'localhost'
      @login_url = LOCAL_URL
      @dashboard_url = LOCAL_DASHBOARD
      @import_prefix = LOCAL_IMPORT_PREFIX
    when 'production', 'prod', 'p'
      @login_url = PROD_URL
    else
      @login_url = STAGE_URL
      @dashboard_url = STAGE_DASHBOARD
      @import_prefix = STAGE_IMPORT_PREFIX
    end
  end

  def set_download_dir
    return ENV['HOME'] + '/Downloads' if ENV['RAILS_ENV'].nil? || ENV['RAILS_ENV'].eql?('development')

    Rails.root.join('tmp')
  end

  # rubocop:disable Lint/RescueException
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Rails/Exit
  def login_to_dashboard
    log_and_puts('*** Logging in to the Dashboard ***')

    begin
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.read_timeout = TIMEOUT # seconds
      @bsess = Watir::Browser.start(@login_url, http_client: client)
    rescue Exception => e
      log_and_puts("       Error trying to initiate browser session #{e.message}...")
      log_and_puts('       Trying again in 10 seconds...')
      sleep(10)
      @bsess = nil
      begin
        client = Selenium::WebDriver::Remote::Http::Default.new
        client.read_timeout = TIMEOUT # seconds
        @bsess = Watir::Browser.start(@login_url, http_client: client)
      rescue Exception => e
        log_and_puts("       Failed again #{e.message}...")
        exit 1
      end
    end
    @bsess.text_field(id: 'user_email').set(@user)
    @bsess.text_field(id: 'user_password').set(@pass)
    @bsess.form(id: 'new_user').submit
  end
  # rubocop:enable Rails/Exit
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Lint/RescueException

  def remove_existing_csv_file_for(table_name)
    log_and_puts("  Removing existing CSV file for #{table_name}")

    return unless File.exist?("#{@download_dir}/#{table_name}.csv")

    File.delete("#{@download_dir}/#{table_name}.csv")
  end

  def download_csv_file_for(table_name)
    log_and_puts("  Downloading CSV file for #{table_name}")

    button = @bsess.link(role: 'button', href: "#{EXPORT_PREFIX}#{table_name}", visible_text: 'Export')
    button.click

    log_and_puts('    Waiting for download to complete...')
    @bsess.wait_until(timeout: TIMEOUT) do
      File.exist?("#{@download_dir}/#{table_name}.csv")
    end
    log_and_puts('    Completed')

    log_and_puts("\n")
  end

  def upload_csv_file_for(table_name)
    log_and_puts("     Uploading CSV file for #{table_name}")
    upload_with_parameters(table_name, 0)
    log_out_and_back_in(table_name)
  end

  def upload_with_parameters(table_name, retry_count = 0)
    log_and_puts("         Uploading #{table_name}")
    button = @bsess.link(role: 'button', href: "#{@import_prefix}#{table_name}", visible_text: 'Upload')
    button.click

    @bsess.text_field(id: 'upload_skip_lines').set(0)
    @bsess.file_field(id: 'upload_upload_file').set("#{@download_dir}/#{table_name}.csv")

    @bsess
      .text_field(id: 'upload_comment')
      .set("Uploaded on #{Time.now.getlocal} from Production export")

    @bsess.form(id: 'new_upload').submit

    if @bsess.link(text: 'View Dashboard').present?
      log_and_puts("         Successfully uploaded #{table_name}")
      @bsess.link(text: 'View Dashboard').click
    else # retry once
      log_and_puts('    Could not find the dashboard link - most likely it failed')
      sleep(30)
      @bsess.goto(@dashboard_url)
      return if retry_count.positive?

      log_out_and_back_in(table_name)
      upload_with_parameters(table_name, 1)
    end
  end

  def log_out_and_back_in(table_name)
    log_and_puts('*** Logging out')
    @bsess.link(text: 'Log Out').click if @bsess.link(text: 'Log Out').present?
    @bsess = nil # close the browser session to free up memory
    log_and_puts ''
    sleep(5)

    if table_name.eql?('Section1015') # last table in the array
      log_and_puts('*** Finished uploading tables ***')
    else
      login_to_dashboard
    end
  end

  def log_and_puts(msg)
    msg = "#{Time.now.getlocal} - #{msg}" if msg.size.positive?
    @eilogger.info(msg)
  end
  # :nocov:
end
# rubocop:enable Metrics/ClassLength
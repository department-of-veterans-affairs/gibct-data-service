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

  def upload_all_table_data
    CSV_TYPES_ALL_TABLES_CLASSES.each do |table_class|
      table_name = table_class.to_s

      # The table is not active yet
      next if table_name.eql?('InstitutionSchoolRating')
      # This table has CORS issues loading to the staging server
      next if table_name.eql?('CipCode') && @login_url.eql?(STAGE_URL)

      upload_csv_file_for(table_name)
    end

    0
  end

  def finalize
    @headless.destroy
    @bsess.close
  end

  private

  def set_logger
    logger_time = Time.now.getlocal.strftime('%Y%m%d_%H%M%S')
    @eilogger = Logger.new(Rails.root.join('log', "export_import_#{logger_time}.log"))
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

  def login_to_dashboard
    log_and_puts('*** Logging in to the Dashboard ***')

    client = Selenium::WebDriver::Remote::Http::Default.new
    client.read_timeout = TIMEOUT # seconds

    @bsess = Watir::Browser.start(@login_url, http_client: client)
    @bsess.text_field(id: 'user_email').set(@user)
    @bsess.text_field(id: 'user_password').set(@pass)
    @bsess.form(id: 'new_user').submit
  end

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

    if table_name.eql?('Weam')
      %w[Weam1 Weam2 Weam3].each { |weam_file_name| remove_existing_csv_file_for(weam_file_name) }

      split_weams_file

      %w[Weam1 Weam2 Weam3].each do |weam_file_name|
        multiple_file_upload = (weam_file_name.include?('Weam1') ? false : true)
        upload_with_parameters('Weam', weam_file_name, multiple_file_upload)
      end
    else
      upload_with_parameters(table_name, table_name, false)
    end

    log_out_and_back_in(table_name)
  end

  def upload_with_parameters(table_name, file_name, multiple_file_upload = false)
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
      @bsess.link(text: 'View Dashboard').click
    else
      log_and_puts('    Could not find the dashboard link - most likely it failed')
      @bsess.goto(@dashboard_url)
    end
  end

  # Weam has approx 75k lines, split into 3 files so that we don't run out of memory in Staging
  def split_weams_file
    file1 = File.open("#{@download_dir}/Weam1.csv", 'w')
    file2 = File.open("#{@download_dir}/Weam2.csv", 'w')
    file3 = File.open("#{@download_dir}/Weam3.csv", 'w')

    File.open("#{@download_dir}/Weam.csv").each_with_index do |row, index|
      case index
      when 0
        file1.write(row)
        file2.write(row)
        file3.write(row)
      when 1..24_999
        file1.write(row)
      when 25_000..49_999
        file2.write(row)
      else
        file3.write(row)
      end
    end

    file1.close
    file2.close
    file3.close
  end

  def log_out_and_back_in(table_name)
    log_and_puts('*** Logging out')
    @bsess.link(text: 'Log Out').click
    log_and_puts ''
    login_to_dashboard unless table_name.eql?('Section1015') # last table in the array
  end

  def log_and_puts(msg)
    msg = "#{Time.now.getlocal} - #{msg}" if msg.size.positive?
    @eilogger.info(msg)
  end
  # :nocov:
end
# rubocop:enable Metrics/ClassLength

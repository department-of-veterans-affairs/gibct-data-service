# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class DashboardExporterImporter
  # :nocov:
  include DashboardWatir

  TABLES_TO_SKIP = %w[CipCode InstitutionSchoolRating VrrapProvider Weam].freeze

  def initialize(user, pass, load_env = nil)
    common_initialize_watir(user, pass, load_env)
  end

  def download_all_table_data
    login_to_dashboard

    CSV_TYPES_ALL_TABLES_CLASSES.each do |table_class|
      table_name = table_class.to_s

      next if TABLES_TO_SKIP.include? table_name

      remove_existing_csv_file_for(table_name)
      download_csv_file_for(table_name)
    end

    # download institutions
    remove_existing_csv_file_for('institutions_version')
    download_csv_file_for('institutions_version')

    0
  end

  # rubocop:disable Lint/RescueException
  def upload_all_table_data
    login_to_dashboard

    CSV_TYPES_ALL_TABLES_CLASSES.each do |table_class|
      table_name = table_class.to_s

      next if TABLES_TO_SKIP.include? table_name
      # Weam  has split files
      next if table_name.include?('Weam')

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

  private

  def set_logger
    logger_time = Time.now.getlocal.strftime('%Y%m%d_%H%M%S')
    log_file_name = Rails.root.join('log', "export_import_#{logger_time}.log")
    @eilogger = Logger.new(log_file_name)
    log_and_puts("***** Starting export_import_#{logger_time} *****")

    # open a terminal and tail the log in it
    `gnome-terminal --title="Tail log #{logger_time}" -- bash -c "tail -f #{log_file_name}; exec bash -i"`
  end

  def remove_existing_csv_file_for(table_name)
    log_and_puts("  Removing existing CSV file for #{table_name}")

    if !table_name.eql?('institutions_version')
      return unless File.exist?("#{@download_dir}/#{table_name}.csv")

      File.delete("#{@download_dir}/#{table_name}.csv")
    else
      institutions_files = Dir.glob("#{@download_dir}/#{table_name}*.csv")
      return if institutions_files.empty?

      institutions_files.each { |file| File.delete(file) }
    end
  end

  def download_csv_file_for(table_name)
    log_and_puts("  Downloading CSV file for #{table_name}")

    button = determine_button_for(table_name)
    button.click

    log_and_puts('    Waiting for download to complete...')

    @bsess.wait_until(timeout: TIMEOUT) do
      check_exists_for(table_name)
    end

    log_and_puts('    Completed')

    log_and_puts("\n")
  end

  def determine_button_for(table_name)
    unless table_name.include?('institutions_version')
      return @bsess.link(role: 'button', href: "#{EXPORT_PREFIX}#{table_name}", visible_text: 'Export')
    end

    @bsess.link(role: 'button', visible_text: 'Download Export CSV')
  end

  def check_exists_for(table_name)
    if !table_name.eql?('institutions_version')
      File.exist?("#{@download_dir}/#{table_name}.csv")
    else
      !Dir.glob("#{download_dir}/#{table_name}*.csv").empty?
    end
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
  # :nocov:
end
# rubocop:enable Metrics/ClassLength

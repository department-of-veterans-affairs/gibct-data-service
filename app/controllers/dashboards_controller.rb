# frozen_string_literal: true

class DashboardsController < ApplicationController
  def index
    @uploads = Upload.last_uploads_rows
    @production_versions = Version.production.newest.includes(:user).limit(1)
    @preview_versions = Version.preview.newest.includes(:user).limit(1)
    @latest_uploads = Upload.since_last_version
    flash_progress_if_needed
  end

  def build
    GeneratePreviewJob.perform_later(current_user)
    # can we take out the unless condition?
    PreviewGenerationStatusInformation.create!(current_progress: 'Preview Version being generated.') unless production?

    redirect_to dashboards_path
  end

  def unlock_generate_button
    begin
      PreviewGenerationStatusInformation.delete_all
      begin
        Version.where(production: false).destroy_all
        flash.notice = 'Unlock completed'
      rescue StandardError => e
        log_error(e)
        flash.error = "Unlock failed on Version: #{e.message}"
      end
    rescue StandardError => e
      log_error(e)
      flash.error = "Unlock failed on PreviewGenerationStatusInformation: #{e.message}"
    end

    redirect_to dashboards_path
  end

  def export
    file_type = params[:csv_type]
    if GROUP_FILE_TYPES_NAMES.include?(file_type)
      send_data Group.export_as_zip(file_type), type: 'application/zip', filename: "#{file_type}.zip"
    else
      klass = csv_model(file_type)

      respond_to do |format|
        format.csv { send_data klass.export, type: 'text/csv', filename: "#{klass.name}.csv" }
      end
    end
  rescue ArgumentError, ActionController::UnknownFormat => e
    log_error(e)
  end

  def export_version
    respond_to do |format|
      format.csv do
        send_data Institution.export_by_version(params[:export_all]),
                  type: 'text/csv',
                  filename: "institutions_version_#{params[:number]}.csv"
      end
    end
  rescue ArgumentError, Common::Exceptions::Internal::RecordNotFound, ActionController::UnknownFormat => e
    log_error(e)
  end

  def export_ungeocodables
    respond_to do |format|
      format.csv do
        send_data Institution.export_ungeocodables(
          Institution.ungeocodables.pluck(
            :institution, :facility_code, :physical_address_1, :physical_address_2, :physical_address_3, :physical_city,
            :physical_state, :physical_zip, :physical_country, :cross, :ope
          )
        ), type: 'text/csv', filename: 'ungeocodables.csv'
      end
    end
  rescue ArgumentError, Common::Exceptions::Internal::RecordNotFound, ActionController::UnknownFormat => e
    log_error(e)
  end

  def export_unaccrediteds
    respond_to do |format|
      format.csv do
        send_data Institution.export_unaccrediteds(
          Institution.unaccrediteds.values
        ), type: 'text/csv', filename: 'unaccrediteds.csv'
      end
    end
  rescue ArgumentError, Common::Exceptions::Internal::RecordNotFound, ActionController::UnknownFormat => e
    log_error(e)
  end

  def export_partials
    respond_to do |format|
      format.csv do
        send_data CrosswalkIssue.export_partials(CrosswalkIssue.export_and_pluck_partials),
                  type: 'text/csv', filename: 'partials.csv'
      end
    end
  rescue ArgumentError, Common::Exceptions::Internal::RecordNotFound, ActionController::UnknownFormat => e
    log_error(e)
  end

  def export_orphans
    respond_to do |format|
      format.csv do
        send_data CrosswalkIssue.export_orphans(CrosswalkIssue.orphans),
                  type: 'text/csv', filename: 'orphans.csv'
      end
    end
  rescue ArgumentError, Common::Exceptions::Internal::RecordNotFound, ActionController::UnknownFormat => e
    log_error(e)
  end

  def api_fetch
    class_nm = CSV_TYPES_HAS_API_TABLE_NAMES.find { |csv_type| csv_type == params[:csv_type] }

    if Upload.fetching_for?(params[:csv_type])
      flash.alert = "#{params[:csv_type]} is already being fetched by another user"
    elsif class_nm.present?
      csv = "#{class_nm}::API_SOURCE".safe_constantize || "#{class_nm} API"
      upload_file(class_nm, csv)
    else
      flash.alert = "#{params[:csv_type]} is not configured to fetch data from an api"
    end

    redirect_to dashboards_path
  end

  def geocoding_issues
    @ungeocodables = Institution.ungeocodables
  end

  def accreditation_issues
    @unaccrediteds = Institution.unaccrediteds
  end

  def unlock_fetches
    if Upload.unlock_fetches
      flash.notice = 'All fetches have been unlocked'
    else
      flash.alert = 'Unlocking fetches failed'
    end

    redirect_to dashboards_path
  end

  private

  def log_error(error)
    Rails.logger.error error.message + error&.backtrace.to_s
    redirect_to dashboards_path, alert: "#{error.message}\n#{error.backtrace[0]}"
  end

  def csv_model(csv_type)
    model = CSV_TYPES_ALL_TABLES_CLASSES.select { |klass| klass.name == csv_type }.first
    return model if model.present?

    raise(ArgumentError, "#{csv_type} is not a valid exportable CSV type") if model.blank?
  end

  def fetch_api_data(api_upload)
    klass = api_upload.csv_type.constantize
    populated = klass.respond_to?(:populate) ? klass.populate : false
    api_upload.update(ok: populated, completed_at: Time.now.utc.to_fs(:db))

    if populated
      message = "#{klass.name}::POPULATE_SUCCESS_MESSAGE".safe_constantize
      return message if message.present?

      "#{klass.name} finished fetching data from its api"
    end
  end

  # :nocov:
  def flash_progress_if_needed
    if PreviewGenerationStatusInformation.exists?
      pgsi = PreviewGenerationStatusInformation.last
      flash.notice = pgsi.current_progress
    end
  end
  # :nocov:

  def upload_file(class_nm, csv)
    if CSV_TYPES_NO_API_KEY_TABLE_NAMES.include?(class_nm)
      klass = Object.const_get(class_nm)

      # HCM is a special case. It may have an xls extension or an xlsx extension. Each quarter
      # this has to be checked and handled appropriately.
      if download_csv(class_nm) && unzip_csv(class_nm)
        upload = Upload.from_csv_type(params[:csv_type])
        upload.user = current_user
        upload.csv =
          case class_nm
          when 'EightKey' # This guy doesn't load properly with roo as is.
            FileTypeConverters::XlsToCsv.new('tmp/eight_key.xls', 'tmp/eight_key.csv').convert_xls_to_csv
          when 'Hcm'
            hcm_spreadsheet_processing(class_nm)
          else
            NoKeyApis::NoKeyApiDownloader::API_DOWNLOAD_CONVERSION_NAMES[class_nm] || "tmp/#{params[:csv_type]}s.csv"
          end

        skipline =
          case class_nm
          when 'Hcm' then 2
          when 'Mou' then 1
          else 0
          end

        file_options = {
          liberal_parsing: upload.liberal_parsing,
          sheets: [{ klass: klass, skip_lines: skipline, clean_rows: upload.clean_rows }]
        }

        klass.load_with_roo(upload.csv, file_options).first
        upload.update(ok: true, completed_at: Time.now.utc.to_fs(:db))
        flash.notice = 'Successfully fetched & uploaded file' if upload.save!
      end
    else
      upload = Upload.new(csv_type: class_nm, user: current_user, csv: csv, comment: "#{class_nm} API Request")
      flash.notice = fetch_api_data(upload) if upload.save!
    end
  rescue StandardError => e
    message = Common::Exceptions::ExceptionHandler.new(e, upload&.csv_type).serialize_error
    upload.update(ok: false, completed_at: Time.now.utc.to_fs(:db), comment: message)

    Rails.logger.error e
    flash.alert = message
  end

  def download_csv(class_nm)
    NoKeyApis::NoKeyApiDownloader.new(class_nm).download_csv
  end

  def unzip_csv(class_nm)
    # Some downloads are not a zip file, so skip and return true
    return true if class_nm.eql?('Hcm') || class_nm.eql?('EightKey') || class_nm.eql?('Mou') || class_nm.eql?('Vsoc')

    # Overwrite extracted file name if Ipeds
    f_name = NoKeyApis::NoKeyApiDownloader::API_DOWNLOAD_CONVERSION_NAMES[class_nm] if class_nm.starts_with?('Ipeds')

    ZipFileUtils::Unzipper.new.unzip_the_file(f_name)
  end

  # Sometimes the file is an xls file and sometimes it is an xlsx file.
  def hcm_spreadsheet_processing(class_nm)
    if NoKeyApis::NoKeyApiDownloader::API_DOWNLOAD_CONVERSION_NAMES[class_nm].end_with?('.xls')
      FileTypeConverters::XlsToCsv.new('tmp/hcm.xls', 'tmp/hcm.csv').convert_xls_to_csv
    else
      NoKeyApis::NoKeyApiDownloader::API_DOWNLOAD_CONVERSION_NAMES[class_nm] || "tmp/#{params[:csv_type]}s.csv"
    end
  end
end

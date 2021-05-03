# frozen_string_literal: true

class DashboardsController < ApplicationController
  def index
    @uploads = Upload.last_uploads_rows

    @production_versions = Version.production.newest.includes(:user).limit(1)
    @preview_versions = Version.preview.newest.includes(:user).limit(1)
    @latest_uploads = Upload.since_last_preview_version
  end

  def build
    results = InstitutionBuilder.run(current_user)

    @version = results[:version]
    @error_msg = results[:error_msg]

    if @error_msg.present?
      flash.alert = "Preview Data not built: #{@error_msg}"
    else
      flash.notice = "Preview Data (#{@version.number}) built successfully"
      flash.alert = results[:messages] if results[:messages]
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
        send_data Institution.export_by_version(params[:number]),
                  type: 'text/csv',
                  filename: "institutions_version_#{params[:number]}.csv"
      end
    end
  rescue ArgumentError, Common::Exceptions::RecordNotFound, ActionController::UnknownFormat => e
    log_error(e)
  end

  def push
    version = Version.current_preview

    if version.blank?
      flash.alert = 'No preview version available'
    else
      version.update(production: true)

      flash.notice = 'Production data updated'

      # Build Sitemap and notify search engines in production only
      ping = request.original_url.include?(GibctSiteMapper::PRODUCTION_HOST)
      GibctSiteMapper.new(ping: ping)

      if Settings.archiver.archive
        # Archive previous versions of generated data
        Archiver.archive_previous_versions
      end
    end

    redirect_to dashboards_path
  end

  def api_fetch
    class_name = CSV_TYPES_HAS_API_TABLE_NAMES.find { |csv_type| csv_type == params[:csv_type] }

    if Upload.fetching_for?(params[:csv_type])
      flash.alert = "#{params[:csv_type]} is already being fetched by another user"
    elsif class_name.present?
      csv = "#{class_name}::API_SOURCE".safe_constantize || "#{class_name} API"
      begin
        api_upload = Upload.new(csv_type: class_name, user: current_user, csv: csv,
                                comment: "#{class_name} API Request")
        flash.notice = fetch_api_data(api_upload) if api_upload.save!
      rescue StandardError => e
        message = Common::Exceptions::ExceptionHandler.new(e, api_upload&.csv_type).serialize_error
        api_upload.update(ok: false, completed_at: Time.now.utc.to_s(:db), comment: message)

        Rails.logger.error e
        flash.alert = message
      end
    else
      flash.alert = "#{params[:csv_type]} is not configured to fetch data from an api"
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
    populated = klass&.respond_to?(:populate) ? klass.populate : false
    api_upload.update(ok: populated, completed_at: Time.now.utc.to_s(:db))

    if populated

      message = "#{klass.name}::POPULATE_SUCCESS_MESSAGE".safe_constantize
      return message if message.present?

      "#{klass.name} finished fetching data from its api"
    end
  end
end

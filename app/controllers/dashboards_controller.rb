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
    end

    redirect_to dashboards_path
  end

  def export
    klass = csv_model(params[:csv_type])

    respond_to do |format|
      format.csv { send_data klass.export, type: 'text/csv', filename: "#{klass.name}.csv" }
    end
  rescue ArgumentError, ActionController::UnknownFormat => e
    Rails.logger.error e.message
    redirect_to dashboards_path, alert: e.message
  end

  def export_version
    respond_to do |format|
      format.csv do
        send_data Institution.export_institutions_by_version(params[:number]),
                  type: 'text/csv',
                  filename: "institutions_version_#{params[:number]}.csv"
      end
    end
  rescue ArgumentError, Common::Exceptions::RecordNotFound, ActionController::UnknownFormat => e
    Rails.logger.error e.message
    redirect_to dashboards_path, alert: e.message
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
    klass = params[:csv_type].constantize
    csv = "#{klass.name}::API_SOURCE".safe_constantize || "#{klass.name} API"
    api_upload = Upload.create(csv_type: params[:csv_type],
                               user: current_user,
                               csv: csv,
                               comment: "#{klass.name} API Request")
    message = fetch_api_data(api_upload) if api_upload.csv_type_check?

    if message
      flash.notice = message
    else
      flash.alert = "#{api_upload.csv_type} is not configured to fetch data from an api"
    end
    redirect_to dashboards_path
  rescue StandardError => e
    message = Common::Exceptions::ExceptionHandler.new(e, upload.csv_type).serialize_error
    Rails.logger.error e
    redirect_to dashboards_path, alert: message
  end

  private

  def csv_model(csv_type)
    model = CSV_TYPES_ALL_TABLES.select { |klass| klass.name == csv_type }.first
    return model if model.present?

    raise(ArgumentError, "#{csv_type} is not a valid CSV type") if model.blank?
  end

  def fetch_api_data(api_upload)
    klass = api_upload.csv_type.constantize
    populated = klass.populate if klass&.respond_to?(:populate)

    api_upload.update(ok: populated, completed_at: Time.now.utc.to_s(:db))

    if populated

      message = "#{klass.name}::POPULATE_SUCCESS_MESSAGE".safe_constantize
      return message if message.present?

      "#{klass.name} finished fetching data from it's api"
    end
  end
end

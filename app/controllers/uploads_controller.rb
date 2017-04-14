# frozen_string_literal: true
class UploadsController < ApplicationController
  VALID_CSVS = InstitutionBuilder::TABLES.map(&:name)

  def index
    @uploads = Upload.paginate(page: params[:page]).order(created_at: :desc)
  end

  def new
    @upload = new_upload(params[:csv_type])
    return if @upload.csv_type_check?

    alert_and_log(@upload.errors.full_messages.join(', '))
    redirect_to dashboards_path
  end

  def create
    @upload = Upload.create(merged_params)

    begin
      failed = load_csv.failed_instances

      @upload.check_for_headers
      header_warnings = @upload.all_warnings

      flash.alert = {}
      flash.alert['The upload succeeded: '] = @upload.csv_type
      flash.alert['But following rows should be checked: '] = failed.map(&:display_errors_with_row) unless failed.empty?
      flash.alert['The following headers should be checked: '] = header_warnings unless header_warnings.empty?

      redirect_to @upload
    rescue StandardError => e
      @upload = new_upload(merged_params[:csv_type])

      alert_and_log("Failed to upload #{original_filename}: #{e.message}\n#{e.backtrace}")
      render :new
    end
  end

  def show
    @upload = Upload.find_by(id: params[:id])
    return if @upload.present?

    alert_and_log("Upload with id: '#{params[:id]}' not found")
    redirect_to uploads_path
  end

  private

  def alert_and_log(message)
    Rails.logger.error message
    flash.alert = message
  end

  def new_upload(csv_type)
    upload = Upload.new(csv_type: csv_type)
    upload.skip_lines = defaults(csv_type)['skip_lines']

    upload
  end

  def load_csv
    return unless @upload.persisted?
    call_load
  end

  def original_filename
    @f ||= upload_params[:upload_file].try(:original_filename)
  end

  def defaults(csv_type)
    Rails.application.config.csv_defaults[csv_type] || Rails.application.config.csv_defaults['generic']
  end

  def merged_params
    upload_params.merge(csv: original_filename, user: current_user)
  end

  def upload_params
    @u ||= params.require(:upload).permit(:csv_type, :skip_lines, :upload_file, :comment)
  end

  def call_load
    file = @upload.upload_file.tempfile
    skip_lines = @upload.skip_lines.try(:to_i)
    data = klass.load(file, skip_lines: skip_lines)

    @upload.update(ok: data.present? && data.ids.present?)
    raise(StandardError, "There was no saved #{klass} data") unless @upload.ok?

    data
  end

  def klass
    @upload.csv_type.constantize
  end
end

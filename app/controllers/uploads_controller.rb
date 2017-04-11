# frozen_string_literal: true
class UploadsController < ApplicationController
  include Flashable

  VALID_CSVS = InstitutionBuilder::TABLES.map(&:name)

  def index
    @uploads = Upload.paginate(page: params[:page]).order(created_at: :desc)
  end

  def new
    @upload = new_upload(params[:csv_type])
    return if @upload.csv_type.blank? || @upload.csv_type_check?

    log_and_display_error(errors_for_alert([@upload]), 'Warning')
    @upload.csv_type = nil
  end

  def create
    @upload = Upload.create(merged_params)

    begin
      data = load_csv
      display_failed_instances(data.failed_instances)

      redirect_to @upload
    rescue StandardError => e
      log_and_display_error(e.message, "Failed to upload #{original_filename}.", e.backtrace)
      @upload = new_upload(merged_params[:csv_type])

      render :new
    end
  end

  def show
    @upload = Upload.find_by(id: params[:id])
    return if @upload.present?

    log_and_display_error("Upload with id: '#{params[:id]}' not found", 'Error')
    redirect_to uploads_path
  end

  private

  def new_upload(csv_type)
    upload = Upload.new(csv_type: csv_type)
    upload.skip_lines = defaults(csv_type)['skip_lines']

    upload
  end

  def display_failed_instances(failed_instances)
    log_and_display_error(errors_for_alert(failed_instances), message_for_notice(failed_instances))
  end

  def log_and_display_error(alert, notice, backtrace = [])
    Rails.logger.error "#{notice}: #{alert}"
    Rails.logger.error backtrace.join("\n") unless backtrace.blank?

    flash.alert = alert
    flash.notice = notice
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
    data = @upload.csv_type.constantize.load(file, skip_lines: @upload.skip_lines.try(:to_i))

    @upload.update(ok: data.present? && data.ids.present?)
    raise StandardError, errors_for_alert([@upload]) unless @upload.ok?

    data
  end
end

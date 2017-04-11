# frozen_string_literal: true
class UploadsController < ApplicationController
  include Flashable

  VALID_CSVS = InstitutionBuilder::TABLES.map(&:name)

  def index
    @uploads = Upload.paginate(page: params[:page]).order(created_at: :desc)
  end

  def new
    csv_type = params[:csv_type]

    @upload = Upload.new(csv_type: csv_type)
    @upload.skip_lines = defaults(csv_type)['skip_lines']

    return if @upload.csv_type.blank? || @upload.csv_type_check?

    flash.alert = errors_for_alert([@upload])
    @upload.csv_type = nil
  end

  def create
    @upload = Upload.create(merged_params)

    begin
      data = load_csv

      failed_instances = data.failed_instances
      warnings = errors_for_alert(failed_instances)

      redirect_to @upload, alert: warnings, notice: message_for_notice(failed_instances)
    rescue StandardError => e
      Rails.logger.error e.message
      render :new, alert: e.message, notice: "Failed to upload #{original_filename}."
    end
  end

  def show
    @upload = Upload.find_by(id: params[:id])
    redirect_to uploads_path, alert: ["Upload with id: '#{params[:id]}' not found"] unless @upload
  end

  private

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
    raise StandardError, 'Uploading failed to return or upload data' unless @upload.ok?

    data
  end
end

# frozen_string_literal: true
class UploadsController < ApplicationController
  include Flashable

  def index
    @uploads = Upload.paginate(page: params[:page]).order(created_at: :desc)
  end

  def new
    csv_type = params[:csv_type]

    @upload = Upload.new(csv_type: csv_type)
    @upload.skip_lines = defaults(csv_type)['skip_lines']
  end

  def create
    @upload = Upload.create(merged_params)
    data = load_csv

    if @upload.ok
      failed_instances = data.failed_instances
      redirect_to @upload, alert: errors_for_alert(failed_instances), notice: message_for_notice(failed_instances)
    else
      render :new, alert: errors_for_alert([@upload]), notice: "Failed to upload #{original_filename}."
    end
  end

  def show
    @upload = Upload.find_by(id: params[:id])
    redirect_to uploads_path, alert: ["Upload with id: '#{params[:id]}' not found"] unless @upload
  end

  private

  def load_csv
    return unless @upload.persisted?

    file = @upload.upload_file.tempfile
    data = @upload.csv_type.constantize.load(file, skip_lines: @upload.skip_lines.try(:to_i))

    @upload.update(ok: data.present? && data.ids.present?)
    data
  end

  def original_filename
    @f ||= upload_params[:upload_file].try(:original_filename)
  end

  def defaults(csv_type)
    Rails.application.config.csv_defaults[csv_type || 'generic']
  end

  def merged_params
    upload_params.merge(csv: original_filename, user: current_user)
  end

  def upload_params
    @u ||= params.require(:upload).permit(:csv_type, :skip_lines, :upload_file, :comment)
  end
end

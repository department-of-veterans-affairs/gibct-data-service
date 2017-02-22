# frozen_string_literal: true
class UploadsController < ApplicationController
  def index
    @uploads = Upload.paginate(page: params[:page]).order(created_at: :desc)
  end

  def new
    csv_type = params[:csv_type]

    @upload = Upload.new(csv_type: csv_type)
    @upload.skip_lines = defaults[csv_type || 'generic']['skip_lines']
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

  def message_for_notice(invalid_records)
    msg = "Uploading #{upload_params[:csv_type]} succeeded"
    msg + (invalid_records.present? ? ' with warnings:' : '.')
  end

  def errors_for_alert(invalid_records)
    error_list = invalid_records[0, 15].map do |record|
      line = record.errors.delete(:base)
      line = line.try(:first) || line
      (line ? "#{line}: " : '') + record.errors.map { |col, msg| "#{col}: #{msg}" }.join(', ')
    end

    remaining = invalid_records.length - 15
    error_list << "Plus #{remaining} #{'warning'.pluralize(remaining)} not listed ..." if remaining.positive?

    error_list
  end

  def original_filename
    @f ||= upload_params[:upload_file].try(:original_filename)
  end

  def defaults
    @defaults ||= YAML.load_file(Rails.root.join('config', 'csv_file_defaults.yml'))
  end

  def merged_params
    upload_params.merge(filename: original_filename, user: current_user)
  end

  def upload_params
    @u ||= params.require(:upload).permit(:csv_type, :skip_lines, :upload_file, :comment)
  end
end

# frozen_string_literal: true

class UploadsController < ApplicationController
  def index
    @uploads = Upload.paginate(page: params[:page]).order(created_at: :desc)
  end

  def new
    @upload = Upload.from_csv_type(params[:csv_type])
    return if @upload.csv_type_check?

    alert_and_log(@upload.errors.full_messages.join(', '))
    redirect_to dashboards_path
  end

  def create
    @upload = Upload.create(merged_params)

    begin
      failed = load_csv.failed_instances
      @upload.check_for_headers

      validation_warnings = failed.sort { |a, b| a.errors[:row].first.to_i <=> b.errors[:row].first.to_i }
                                  .map(&:display_errors_with_row)
      header_warnings = @upload.all_warnings

      flash.alert = { 'The upload succeeded: ' => @upload.csv_type }

      flash.alert['The following rows should be checked: '] = validation_warnings unless validation_warnings.empty?
      flash.alert['The following headers should be checked: '] = header_warnings unless header_warnings.empty?

      redirect_to @upload
    rescue StandardError => e
      @upload = Upload.from_csv_type(merged_params[:csv_type])

      alert_and_log("Failed to upload #{original_filename}: #{e.message}\n#{e.backtrace[0]}", e)
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

  def alert_and_log(message, error = nil)
    Rails.logger.error message + (error&.backtrace).to_s
    flash.alert = message
  end

  def load_csv
    return unless @upload.persisted?

    call_load
  end

  def original_filename
    @original_filename ||= upload_params[:upload_file].try(:original_filename)
  end

  def merged_params
    upload_params.merge(csv: original_filename, user: current_user)
  end

  def upload_params
    @upload_params ||= params.require(:upload).permit(:csv_type, :skip_lines, :col_sep, :upload_file, :comment)
  end

  def call_load
    file = @upload.upload_file.tempfile
    skip_lines = @upload.skip_lines.try(:to_i)
    col_sep = @upload.col_sep

    CrosswalkIssue.delete_all if [Crosswalk, IpedsHd, Weam].include?(klass)

    data = klass.load(file, skip_lines: skip_lines, col_sep: col_sep)

    CrosswalkIssue.rebuild if [Crosswalk, IpedsHd, Weam].include?(klass)

    @upload.update(ok: data.present? && data.ids.present?)
    error_msg = "There was no saved #{klass} data. Please check \"Skip lines before header\" or \"Column separator\"."
    raise(StandardError, error_msg) unless @upload.ok?

    data
  end

  def klass
    @upload.csv_type.constantize
  end
end

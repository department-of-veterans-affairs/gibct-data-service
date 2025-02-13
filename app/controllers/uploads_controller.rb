# frozen_string_literal: true

class UploadsController < ApplicationController
  def index
    @uploads = Upload.paginate(page: params[:page]).order(created_at: :desc)
  end

  def new
    @upload = Upload.from_csv_type(params[:csv_type])

    @extensions = upload_settings.extensions.single.join(', ')

    return csv_requirements if @upload.csv_type_check?

    alert_and_log(@upload.errors.full_messages.join(', '))
    redirect_to dashboards_path
  end

  def create
    @upload = Upload.create(merged_params)
    begin
      data = UploadFileProcessor.new(@upload).load_file
      alert_messages(data)
      data_results = data[:results]

      @upload.update(ok: data_results.present? && data_results.ids.present?, completed_at: Time.now.utc.to_fs(:db))
      error_msg = "There was no saved #{klass} data. Please check the file or \"Skip lines before header\"."
      raise(StandardError, error_msg) unless @upload.ok?

      redirect_to @upload
    rescue StandardError => e
      alert_failed_upload(e)
      render :new
    end
  end

  def show
    @upload = Upload.find_by(id: params[:id])

    csv_requirements if @upload.present?
    return if @upload.present?

    alert_and_log("Upload with id: '#{params[:id]}' not found")
    redirect_to uploads_path
  end

  # File split into smaller blobs on client side and uploaded in series of #create_async requests
  # which reassemble blobs into original file server side
  def create_async
    previous_upload = Upload.find_by(id: async_params[:upload_id])
    previous_upload&.update(upload_file: merged_params[:upload_file])
    @upload = previous_upload || Upload.create(**merged_params, queued_at: Time.now.utc.to_fs(:db))
    @upload.create_or_concat_blob

    if final_upload?
      @upload.update(status_message: 'queued for upload')
      ProcessUploadJob.perform_later(@upload)
    end

    render json: { id: @upload.id }
  rescue StandardError => e
    @upload&.cancel!
    alert_failed_upload(e)
    render json: { error: e }, status: :internal_server_error
  end

  def cancel_async
    @upload = Upload.find_by(id: params[:id])
    canceled = @upload.cancel!
    raise StandardError, "Failed to cancel upload #{original_filename}" unless canceled

    render json: { canceled: }
  rescue StandardError => e
    alert_and_log("#{e.message}\n#{e.backtrace[0]}", e)
    render json: { error: e }, status: :unprocessable_entity
  end

  # Client polls server for async upload status until upload complete or inactive
  def async_status
    @upload = Upload.find_by(id: params[:id])

    async_status = {
      message: @upload.status_message,
      active: @upload.active?,
      ok: @upload.ok?,
      canceled: @upload.canceled_at.present?,
      type: @upload.csv_type
    }

    if @upload.completed_at && @upload.alerts.present?
      @upload.alerts => { csv_success:, warning: }
      @upload.update(status_message: nil)
      flash[:csv_success] = csv_success if csv_success
      flash[:warning] = warning
    end

    render json: { async_status: }
  rescue StandardError => e
    render json: { error: e }, status: :internal_server_error
  end

  private

  def csv_requirements
    @requirements = [RooHelper::Shared.valid_col_seps] + UploadTypes::UploadRequirements.requirements_messages(klass)
    @custom_batch_validator = "#{klass.name}Validator::REQUIREMENT_DESCRIPTIONS".safe_constantize
    @inclusion = UploadTypes::UploadRequirements.validation_messages_inclusion(klass)
  end

  def alert_messages(data)
    results_breakdown = UploadFileProcessor.parse_results(data)
    results_breakdown => { valid_rows:,
                          total_rows_count:,
                          failed_rows_count:,
                          header_warnings:,
                          validation_warnings:}

    if valid_rows.positive?
      flash[:csv_success] = {
        total_rows_count: total_rows_count.to_s,
        valid_rows: valid_rows.to_s,
        failed_rows_count: failed_rows_count.to_s
      }.compact
    end

    flash[:warning] = {
      'The following headers should be checked: ': (header_warnings unless header_warnings.empty?),
      'The following rows should be checked: ': (validation_warnings unless validation_warnings.empty?)
    }.compact
  end

  def alert_failed_upload(error)
    @upload = Upload.from_csv_type(merged_params[:csv_type])
    @extensions = upload_settings.extensions.single.join(', ')
    csv_requirements if @upload.csv_type_check?
    alert_and_log("Failed to upload #{original_filename}: #{error.message}\n#{error.backtrace[0]}", error)
  end

  def original_filename
    @original_filename ||= upload_params[:upload_file].try(:original_filename)
  end

  def merged_params
    upload_params.merge(csv: original_filename, user: current_user).except(:metadata)
  end

  def upload_params
    upload_params = params.require(:upload).permit(
      :csv_type, :skip_lines, :upload_file, :comment, :multiple_file_upload,
      metadata: [:upload_id, { count: %i[current total] }]
    )

    upload_params[:multiple_file_upload] = true if upload_params[:multiple_file_upload].eql?('true')
    @upload_params ||= upload_params
  end

  def async_params
    upload_params[:metadata].tap do |metadata|
      metadata[:count]&.transform_values!(&:to_i)
    end
  end

  def final_upload?
    async_params[:count][:current] == async_params[:count][:total]
  end

  def klass
    @upload.csv_type.constantize
  end

  def upload_settings
    @upload_settings ||= @upload.async_enabled? ? Settings.async_upload : Settings.roo_upload
  end
end

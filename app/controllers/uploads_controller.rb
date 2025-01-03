# frozen_string_literal: true

class UploadsController < ApplicationController
  def index
    @uploads = Upload.paginate(page: params[:page]).order(created_at: :desc)
  end

  def new
    @upload = Upload.from_csv_type(params[:csv_type])
    @extensions = Settings.roo_upload.extensions.single.join(', ')

    return csv_requirements if @upload.csv_type_check?

    alert_and_log(@upload.errors.full_messages.join(', '))
    redirect_to dashboards_path
  end

  def create
    begin
      @upload = Upload.create(merged_params)

      data = load_file
      alert_messages(data)
      data_results = data[:results]

      @upload.update(ok: data_results.present? && data_results.ids.present?, completed_at: Time.now.utc.to_fs(:db))
      error_msg = "There was no saved #{klass} data. Please check the file or \"Skip lines before header\"."
      raise(StandardError, error_msg) unless @upload.ok?

      redirect_to @upload
    rescue StandardError => e
      @upload = Upload.from_csv_type(merged_params[:csv_type])
      @extensions = Settings.roo_upload.extensions.single.join(', ')
      csv_requirements if @upload.csv_type_check?
      alert_and_log("Failed to upload #{original_filename}: #{e.message}\n#{e.backtrace[0]}", e)
      render :new
    end
  end

  # To avoid timeout, custom logic in upload.js breaks file into smaller blobs and uploads each blob
  # separately to simulate multiple file upload.
  # Reassemble blob into single file and load data via async job.
  def create_async
    begin
      previous_upload = Upload.find_by(id: async_params[:upload_id])&.tap do |upload|
        upload.update(upload_file: merged_params[:upload_file])
      end
      # Create and update only one upload record to track blob content across multiple uploads
      @upload = previous_upload || Upload.create(merged_params)
      @upload.create_or_concat_blob

      if async_params[:count][:current] == async_params[:count][:total]
        # Queue async load data job
      end
      respond_to do |format|
        format.js { render json: { upload_id: @upload.id } }
      end
    rescue StandardError => e
      @upload = Upload.from_csv_type(merged_params[:csv_type])
      @extensions = Settings.roo_upload.extensions.single.join(', ')
      csv_requirements if @upload.csv_type_check?
      alert_and_log("Failed to upload #{original_filename}: #{e.message}\n#{e.backtrace[0]}", e)
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

  private

  def csv_requirements
    @requirements = [RooHelper::Shared.valid_col_seps] + UploadTypes::UploadRequirements.requirements_messages(klass)
    @custom_batch_validator = "#{klass.name}Validator::REQUIREMENT_DESCRIPTIONS".safe_constantize
    @inclusion = UploadTypes::UploadRequirements.validation_messages_inclusion(klass)
  end

  def alert_messages(data)
    results = data[:results]

    total_rows_count = results.ids.length
    failed_rows = results.failed_instances
    failed_rows_count = failed_rows.length
    valid_rows = total_rows_count - failed_rows_count
    validation_warnings = failed_rows.sort { |a, b| a.errors[:row].first.to_i <=> b.errors[:row].first.to_i }
                                     .map(&:display_errors_with_row)
    header_warnings = data[:header_warnings]

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

  def original_filename
    @original_filename ||= upload_params[:upload_file].try(:original_filename)
  end

  def merged_params
    @merged_params ||= upload_params.except(:async).merge(csv: original_filename, user: current_user)
  end

  def upload_params
    upload_params = params.require(:upload).permit(
      :csv_type, :skip_lines, :upload_file, :comment, :multiple_file_upload,
      async: [:upload_id, count: [:current, :total]]
    )

    upload_params[:multiple_file_upload] = true if upload_params[:multiple_file_upload].eql?('true')
    upload_params.dig(:async, :count).try(:transform_values!, &:to_i)
    @upload_params ||= upload_params
  end

  def async_params
    @async_params ||= upload_params[:async]
  end

  def load_file
    return unless @upload.persisted?

    file = @upload.upload_file.tempfile

    CrosswalkIssue.delete_all if [Crosswalk, IpedsHd, Weam].include?(klass)

    # first is used because when called from standard upload process
    # only a single set of results is returned
    file_options = { liberal_parsing: @upload.liberal_parsing,
                     sheets: [{ klass: klass, skip_lines: @upload.skip_lines.try(:to_i),
                                clean_rows: @upload.clean_rows,
                                multiple_files: @upload_params[:multiple_file_upload] }] }
    data = klass.load_with_roo(file, file_options).first

    CrosswalkIssue.rebuild if [Crosswalk, IpedsHd, Weam].include?(klass)

    data
  end

  def klass
    @upload.csv_type.constantize
  end
end

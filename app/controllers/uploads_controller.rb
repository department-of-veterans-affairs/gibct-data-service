# frozen_string_literal: true

class UploadsController < ApplicationController
  before_action :exclude_online_types, only: %i[new create show]

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
    @upload = find_or_create_upload

    begin
      data = load_file
      alert_messages(data)
      data_results = data[:results]

      update_upload(data_results)
      inspect_results

      return redirect_to @upload unless sequential?

      render json: { upload: { id: @upload.id } }
    rescue StandardError => e
      handle_upload_error(e)

      return render :new unless sequential?

      render json: { error: e }, status: :internal_server_error
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

  # If sequential upload, use one upload object to track multiple part uploads
  def find_or_create_upload
    return Upload.create(merged_params) if first_upload?

    Upload.find_by(id: sequence_params[:id])&.tap do |obj|
      obj.update(upload_file: merged_params[:upload_file])
    end
  end

  def update_upload(results)
    return if sequence_incomplete?

    @upload.update(ok: results.present? && results.ids.present?)
    @upload.update(completed_at: Time.now.utc.to_fs(:db)) unless needs_retry?
  end

  def inspect_results
    return if @upload.ok? || needs_retry?

    error_msg = "There was no saved #{klass} data. Please check the file or \"Skip lines before header\"."
    raise(StandardError, error_msg)
  end

  def handle_upload_error(err)
    @upload = Upload.from_csv_type(merged_params[:csv_type])
    @extensions = Settings.roo_upload.extensions.single.join(', ')
    csv_requirements if @upload.csv_type_check?
    alert_and_log("Failed to upload #{original_filename}: #{err.message}\n#{err.backtrace[0]}", err)
    rollback_upload_sequence if sequential? && sequence_params[:retries].zero?
  end

  # If sequential upload, append alerts from previous uploads in sequence
  def alert_messages(data)
    parse_results(data) => { total_rows_count:,
                             valid_rows:,
                             failed_rows_count:,
                             validation_warnings: }

    update_success_alerts({ total_rows_count:, valid_rows:, failed_rows_count: }) if valid_rows.positive?

    update_warning_alerts({ 'The following headers should be checked: ': data[:header_warnings],
                            'The following rows should be checked: ': validation_warnings })
  end

  def parse_results(data)
    results = data[:results]
    failed_rows = results.failed_instances
    validation_warnings = failed_rows.sort { |a, b| a.errors[:row].first.to_i <=> b.errors[:row].first.to_i }
                                     .map(&:display_errors_with_row)
    total_rows_count = results.ids.length
    failed_rows_count = failed_rows.length

    {
      total_rows_count:,
      failed_rows_count:,
      validation_warnings:,
      valid_rows: total_rows_count - failed_rows_count
    }
  end

  def update_success_alerts(successes)
    alerts = update_alert(successes) { |key| flash[:csv_success][key].to_i }
    flash[:csv_success] = alerts.transform_values(&:to_s).compact
  end

  def update_warning_alerts(warnings)
    alerts = update_alert(warnings) { |key| flash[:warning][key] || [] }
    flash[:warning] = alerts.reject { |_k, value| value.empty? }
  end

  # Concat success and warning alerts if sequential upload
  def update_alert(hash)
    return hash if first_upload?

    hash.each do |key, value|
      combined = yield(key) + value
      hash[key] = combined.then { |sum| sum.is_a?(Array) ? sum.uniq : sum }
    end
  end

  def original_filename
    @original_filename ||= upload_params[:upload_file].try(:original_filename)
  end

  def merged_params
    upload_params.merge(csv: original_filename, user: current_user).except(:sequence)
  end

  def upload_params
    upload_params = params.require(:upload).permit(
      :csv_type, :skip_lines, :upload_file, :comment, :multiple_file_upload,
      sequence: %i[current total id retries]
    )

    upload_params[:multiple_file_upload] = true if upload_params[:multiple_file_upload].eql?('true')
    @upload_params ||= upload_params
  end

  def load_file
    return unless @upload.persisted?

    file = @upload.upload_file.tempfile

    CrosswalkIssue.delete_all if [Crosswalk, IpedsHd, Weam].include?(klass)

    # first is used when called from standard upload process
    # because only a single set of results is returned
    file_options = { liberal_parsing: @upload.liberal_parsing,
                     sheets: [{ klass: klass, skip_lines: @upload.skip_lines.to_i,
                                clean_rows: @upload.clean_rows,
                                multiple_files: @upload_params[:multiple_file_upload] }] }
    # If sequential upload, offset first line to capture csv_row relative to original upload
    file_options[:sheets][0][:first_line] = klass.last.csv_row + 1 unless first_upload?
    data = klass.load_with_roo(file, file_options).first

    CrosswalkIssue.rebuild if [Crosswalk, IpedsHd, Weam].include?(klass)

    YellowRibbonDegreeLevelTranslation.generate_guesses_for_unmapped_values if klass == YellowRibbonProgramSource

    data
  end

  def sequence_params
    @sequence_params ||= upload_params[:sequence]&.transform_values(&:to_i)
  end

  def sequential?
    sequence_params.present?
  end

  def first_upload?
    return true unless sequential?

    sequence_params[:current] == 1
  end

  def sequence_incomplete?
    sequential? && sequence_params[:current] < sequence_params[:total]
  end

  # Retries implemented when sequential upload fails
  def needs_retry?
    sequential? && !@upload.ok && sequence_params[:retries].positive?
  end

  def rollback_upload_sequence
    flash[:csv_success]&.clear
    klass.in_batches.delete_all
  end

  def klass
    @upload.csv_type.constantize
  end

  # Online Upload types cannot be created/updated via HTTP requests
  def exclude_online_types
    return unless CalculatorConstant.versioning_enabled?

    csv_type = params[:csv_type] || params.dig(:upload, :csv_type)
    redirect_to dashboards_path if ONLINE_TYPES_NAMES.map(&:name).include?(csv_type)
  end
end

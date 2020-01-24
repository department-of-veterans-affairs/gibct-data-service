# frozen_string_literal: true

class UploadsController < ApplicationController
  def index
    @uploads = Upload.paginate(page: params[:page]).order(created_at: :desc)
  end

  def new
    @upload = Upload.from_csv_type(params[:csv_type])

    if @upload.csv_type_check?
      @requirements = requirements_messages
      return
    end

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

  def options
    { skip_lines: @upload.skip_lines.try(:to_i),
      col_sep: @upload.col_sep,
      force_simple_split: @upload.force_simple_split,
      strip_chars_from_headers: @upload.strip_chars_from_headers }
  end

  def call_load
    file = @upload.upload_file.tempfile

    CrosswalkIssue.delete_all if [Crosswalk, IpedsHd, Weam].include?(klass)

    data = klass.load(file, options)

    CrosswalkIssue.rebuild if [Crosswalk, IpedsHd, Weam].include?(klass)

    @upload.update(ok: data.present? && data.ids.present?, completed_at: Time.now.utc.to_s(:db))

    error_msg = "There was no saved #{klass} data. Please check \"Skip lines before header\" or \"Column separator\"."
    raise(StandardError, error_msg) unless @upload.ok?

    data
  end

  def klass
    @upload.csv_type.constantize
  end

  def requirements_messages
    messages = validation_messages
    # this a call to custom validators that are not listed inside the class
    custom_batch_validator_messages = "#{klass.name}Validator::REQUIREMENT_DESCRIPTIONS".safe_constantize
    messages.push(*custom_batch_validator_messages)

    messages.compact
  end

  def validation_messages
    klass.validators.map do |validations|
      case validations
      when ActiveRecord::Validations::PresenceValidator
        generic_requirement_message('These columns must have a value: ', validations)
      when ActiveModel::Validations::InclusionValidator
        inclusion_requirement_message(validations)
      when ActiveModel::Validations::NumericalityValidator
        generic_requirement_message('These columns can only contain numeric values: ', validations)
      when ActiveRecord::Validations::UniquenessValidator
        generic_requirement_message('These columns should contain unique values: ', validations)
      end
    end
  end

  def affected_attributes(validations)
    validations.attributes
               .map { |column| csv_column_name(column).to_s }
               .select(&:present?) # derive_dependent_columns or columns not in CSV_CONVERTER_INFO will be blank
               .join(', ')
  end

  def csv_column_name(column)
    klass::CSV_CONVERTER_INFO.select { |_k, v| v[:column] == column }.keys.join(', ')
  end

  def generic_requirement_message(message, validations)
    message + affected_attributes(validations)
  end

  def inclusion_requirement_message(validations)
    'For column ' + affected_attributes(validations) + ' values must be one of these values: ' +
      validations.options[:in].map(&:to_s).join(', ')
  end
end

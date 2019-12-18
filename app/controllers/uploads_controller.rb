# frozen_string_literal: true

class UploadsController < ApplicationController
  def index
    @uploads = Upload.paginate(page: params[:page]).order(created_at: :desc)
  end

  def new
    @upload = new_upload(params[:csv_type])
    @validators = validators_messages
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
      @upload = new_upload(merged_params[:csv_type])

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

  def new_upload(csv_type)
    upload = Upload.new(csv_type: csv_type)
    upload.skip_lines = defaults(csv_type)['skip_lines']
    upload.col_sep = defaults(csv_type)['col_sep']

    upload
  end

  def load_csv
    return unless @upload.persisted?

    call_load
  end

  def original_filename
    @original_filename ||= upload_params[:upload_file].try(:original_filename)
  end

  def defaults(csv_type)
    Rails.application.config.csv_defaults[csv_type] || Rails.application.config.csv_defaults['generic']
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
    data = klass.load(file, skip_lines: skip_lines, col_sep: col_sep)

    @upload.update(ok: data.present? && data.ids.present?)
    error_msg = "There was no saved #{klass} data. Please check \"Skip lines before header\" or \"Column separator\"."
    raise(StandardError, error_msg) unless @upload.ok?

    data
  end

  def klass
    @upload.csv_type.constantize
  end

  def validators_messages
    messages = klass.validators.map{ |validations|
      if validations.class == ActiveRecord::Validations::PresenceValidator
        generic_validator("These columns must have a value: ", validations)
      elsif validations.class == ActiveModel::Validations::InclusionValidator
        inclusion_validator(validations)
      elsif  validations.class == ActiveModel::Validations::NumericalityValidator
        generic_validator("These columns can only contain numeric values: ", validations)
      elsif validations.class == ActiveRecord::Validations::UniquenessValidator
        generic_validator("These columns should contain unique values: ", validations)
      end
    }.select(&:present?)
    
    # this a call to custom validators that are not listed inside the class
    validator_klass = "#{klass.name}Validator".safe_constantize
    messages.push(*validator_klass::VALIDATION_DESCRIPTIONS) if validator_klass.present? &&
        defined? validator_klass::VALIDATION_DESCRIPTIONS

    messages
  end

  def map_attributes(validations)
    validations.attributes.map(&:to_s).join(', ')
  end

  def generic_validator(message, validations)
    message + map_attributes(validations)
  end

  def inclusion_validator(validations)
    "For column " + map_attributes(validations) + " values must be one of these values: " + validations.options[:in].map(&:to_s).join(', ')
  end
end

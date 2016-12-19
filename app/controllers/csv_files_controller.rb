# frozen_string_literal: true
class CsvFilesController < ApplicationController
  include Alertable

  def index
    @csv_files = CsvFile.all
  end

  def show
    @csv_file = CsvFile.find(params[:id])

    if @csv_file.present?
      render :show
    else
      flash_alert(@csv_file.errors.full_messages)
      render :index
    end
  end

  def new
    @csv_file = CsvFile.new
    @csv_file.user = current_user.email
    return unless params[:csv_type].present?

    @csv_file.csv_type = params[:csv_type]
    @csv_file.skip_lines_before_header = defaults('skip_lines_before_header')
    @csv_file.skip_lines_after_header = defaults('skip_lines_after_header')
    @csv_file.delimiter = defaults('delimiter')
  end

  def create
    @csv_file = CsvFile.new(csv_file_params)
    @csv_file.name = csv_file_params[:upload_file].try(:original_filename)
    @csv_file.user = current_user.try(:email)

    if save_success?
      redirect_to @csv_file
    else
      flash_alert(@csv_file.errors.full_messages)
      redirect_to new_csv_file_path(csv_type: @csv_file.csv_type)
    end
  end

  protected

  def csv_file_params
    params.require(:csv_file).permit(
      :csv_type, :upload_file, :description, :skip_lines_before_header, :skip_lines_after_header, :delimiter
    )
  end

  def defaults(key)
    @default ||= CsvFile.defaults_for(params[:csv_type])
    @default[key]
  end

  def flash_alert(errors)
    flash.alert = CsvFilesController.pretty_error(errors, 'Errors prohibited this file from being saved:')
  end

  def save_success?
    @csv_file.save && !@csv_file.result.casecmp('failed').zero?
  end
end

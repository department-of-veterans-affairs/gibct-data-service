# frozen_string_literal: true
class CsvFilesController < ApplicationController
  include Alertable

  def index
    @csv_files = CsvFile.all.paginate(page: params[:page])
  end

  def show
    @csv_file = CsvFile.find(params[:id])
    render :show
  rescue ActiveRecord::RecordNotFound
    flash_alert(["Csv File record with id = #{params[:id]} was not found"], 'Bad Parameter:')
    redirect_to csv_files_path
  end

  def new
    @csv_file = CsvFile.new
    @csv_file.user = current_user
    return unless params[:csv_type].present?

    @csv_file.csv_type = params[:csv_type]
    @csv_file.skip_lines_before_header = defaults('skip_lines_before_header')
    @csv_file.skip_lines_after_header = defaults('skip_lines_after_header')
    @csv_file.delimiter = defaults('delimiter')
  end

  def create
    @csv_file = CsvFile.new(csv_file_params)
    @csv_file.name = csv_file_params[:upload_file].try(:original_filename)
    @csv_file.user = current_user

    if save_success?
      redirect_to @csv_file
    else
      flash_alert(@csv_file.errors.full_messages)
      redirect_to new_csv_file_path(csv_type: @csv_file.csv_type)
    end
  end

  def defaults(key)
    @default ||= CsvFile.defaults_for(params[:csv_type])
    @default[key]
  end

  protected

  def csv_file_params
    params.require(:csv_file).permit(
      :csv_type, :upload_file, :description, :skip_lines_before_header, :skip_lines_after_header, :delimiter
    )
  end

  def flash_alert(errors, label = 'Errors prohibited this file from being saved:')
    flash.alert = CsvFilesController.pretty_error(errors, label)
  end

  def save_success?
    @csv_file.save && !@csv_file.result.casecmp('failed').zero?
  end
end

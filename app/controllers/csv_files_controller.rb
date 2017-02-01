class CsvFilesController < ApplicationController
  include Alertable

  before_action :authenticate_user!
  before_action :set_csv_file, only: [:show, :destroy, :send_csv_file]

  #############################################################################
  ## index
  #############################################################################
  def index
    @csv_files = CsvFile.all.order(:upload_date, :type)

    respond_to do |format|
      format.html
    end
  end

  #############################################################################
  ## new
  #############################################################################
  def new
    cft = params[:type] || 'AccreditationCsvFile'
    @csv_file = CsvFile.new(type: cft)
    @csv_types = CsvFilesController.get_csv_file_types

    respond_to do |format|
      format.html
    end
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    begin
      @csv_file = CsvFile.new(type: csv_file_params[:type])
      @csv_file.delimiter = csv_file_params[:delimiter]
      @csv_file.upload = csv_file_params[:upload]
    rescue StandardError => e
      @csv_file = CsvFile.new if @csv_file.nil?
      @csv_file.errors[:base] << e.message
    end

    respond_to do |format|
      if @csv_file.errors.blank? && @csv_file.save
        format.html { redirect_to @csv_file, notice: "#{@csv_file.name} saved." }
      else
        @csv_file = CsvFile.new if @csv_file.nil?
        @csv_types = CsvFilesController.get_csv_file_types

        label = 'Errors prohibited this file from being saved:'
        errors = @csv_file.errors.full_messages
        flash.alert = CsvFilesController.pretty_error(label, errors).html_safe

        format.html { render :new }
      end
    end
  end

  #############################################################################
  ## show
  #############################################################################
  def show
    respond_to do |format|
      format.html
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @csv_file.destroy

    respond_to do |format|
      format.html do
        redirect_to csv_files_url,
                    notice: "#{@csv_file.name} was successfully destroyed."
      end
    end
  end

  #############################################################################
  ## send_csv_file
  ## Downloads the data associated with a csv file.
  #############################################################################
  def send_csv_file
    if @csv_file.present?
      data = CsvStorage.find_by(csv_file_type: @csv_file.type).try(:data_store)
      send_data(data, filename: @csv_file.name) if data.present?
    end
  end

  #############################################################################
  ## set_csv_file
  ## Obtains the model instance from the id parameter.
  #############################################################################
  def set_csv_file
    @csv_file = CsvFile.find(params[:id])
  end

  #############################################################################
  ## csv_file_params
  ## Strong parameters
  #############################################################################
  def csv_file_params
    params.require(:csv_file).permit(:delimiter, :upload, :type)
  end
end

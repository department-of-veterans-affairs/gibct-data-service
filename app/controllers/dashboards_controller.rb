class DashboardsController < ApplicationController
	include Alertable
	
	before_action :authenticate_user! 
	 
  #############################################################################
  ## index
  #############################################################################
	def index
    @csv_types = CsvFile.types

    respond_to do |format|
      format.html
    end
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @data_csv = DataCsv.new

    begin
      raise StandardError.new("Missing csv files") if !DataCsv.complete?

      DataCsv.build_data_csv
    rescue StandardError => e 
      @data_csv.errors[:base] << e.message
    end

    respond_to do |format|
      if @data_csv.errors.blank?
        format.html { redirect_to data_csvs_path, notice: "DataCsv built."}
      else
        label = "Errors prohibited data_csv from being built:"
        errors = @data_csv.errors.full_messages
        flash.alert = CsvFilesController.pretty_error(label, errors).html_safe

        @csv_types = CsvFile.types
        format.html { render :index }
      end
    end
  end

  #############################################################################
  ## export
  #############################################################################
  def export
    @data_csv = DataCsv.new

    begin
      raise StandardError.new("Missing csv files") if !DataCsv.complete?

      csv = DataCsv.to_csv
    rescue StandardError => e 
      @data_csv.errors[:base] << e.message
    end

    respond_to do |format|
      if @data_csv.errors.blank?
        format.csv { send_data csv }
      else
        label = "Errors prohibited data.csv from being exported:"
        errors = @data_csv.errors.full_messages
        flash.alert = CsvFilesController.pretty_error(label, errors).html_safe

        @csv_types = CsvFile.types
        format.html { render :index }
      end
    end    
  end
end

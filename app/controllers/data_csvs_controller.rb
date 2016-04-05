class DataCsvsController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_data_csv, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @data_csvs = DataCsv.order(:facility_code, :ope6, :cross).paginate(:page => params[:page])
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
  ## new
  #############################################################################
  def new
    @data_csv = DataCsv.new
        
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @data_csv = DataCsv.create(data_csv_params)

    respond_to do |format|
      if @data_csv.persisted?
        format.html { redirect_to @data_csv, notice: "#{@data_csv.institution} created."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @data_csv.errors.full_messages
        flash.alert = DataCsvsController.pretty_error(label, errors).html_safe

        format.html { render :new }
      end
    end
  end

  #############################################################################
  ## edit
  #############################################################################
  def edit
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## update
  #############################################################################
  def update
    rc = @data_csv.update(data_csv_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @data_csv, notice: "#{@data_csv.institution} updated."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @data_csv.errors.full_messages
        flash.alert = DataCsvsController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @data_csv.destroy

    respond_to do |format|
      format.html { redirect_to data_csvs_url, 
          notice: "#{@data_csv.institution} was successfully destroyed." }
    end
  end

  #############################################################################
  ## set_data_csv
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_data_csv
    @data_csv = DataCsv.find(params[:id])
  end

  #############################################################################
  ## data_csv_params
  ## Strong parameters
  #############################################################################  
  def data_csv_params
    params.require(:data_csv).permit(
      :facility_code, :institution, :type, :city, :state, :zip, :country, :bah,
      :accredited, :poe, :yr, :poo_status, :applicable_law_codes, 
      :institution_of_higher_learning_indicator, :ojt_indicator, 
      :correspondence_indicator, :flight_indicator, 
      :non_college_degree_indicator, :ope, :cross
    )
  end
end

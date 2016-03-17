class VaCrosswalksController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_va_crosswalk, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @va_crosswalks = VaCrosswalk.paginate(:page => params[:page])
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
    @va_crosswalk = VaCrosswalk.new
        
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @va_crosswalk = VaCrosswalk.create(va_crosswalk_params)

    respond_to do |format|
      if @va_crosswalk.persisted?
        format.html { redirect_to @va_crosswalk, notice: "#{@va_crosswalk.institution} created."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @va_crosswalk.errors.full_messages
        flash.alert = VaCrosswalksController.pretty_error(label, errors).html_safe

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
    rc = @va_crosswalk.update(va_crosswalk_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @va_crosswalk, notice: "#{@va_crosswalk.institution} updated."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @va_crosswalk.errors.full_messages
        flash.alert = VaCrosswalksController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @va_crosswalk.destroy

    respond_to do |format|
      format.html { redirect_to va_crosswalks_url, 
          notice: "#{@va_crosswalk.institution} was successfully destroyed." }
    end
  end

  #############################################################################
  ## set_va_crosswalk
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_va_crosswalk
    @va_crosswalk = VaCrosswalk.find(params[:id])
  end

  #############################################################################
  ## csv_file_params
  ## Strong parameters
  #############################################################################  
  def va_crosswalk_params
    params.require(:va_crosswalk).permit(
      :facility_code, :institution, :city, :state, :ope, :cross, :notes
    )
  end
end

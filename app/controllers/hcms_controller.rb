class HcmsController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_hcm, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @hcms = Hcm.paginate(:page => params[:page])
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
    @hcm = Hcm.new
        
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @hcm = Hcm.create(hcm_params)

    respond_to do |format|
      if @hcm.persisted?
        format.html { redirect_to @hcm, notice: "#{@hcm.institution} created."}
      else
        label = "Errors hcm this file from being saved:"
        errors = @hcm.errors.full_messages
        flash.alert = HcmsController.pretty_error(label, errors).html_safe

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
    rc = @hcm.update(hcm_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @hcm, notice: "#{@hcm.institution} updated."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @hcm.errors.full_messages
        flash.alert = HcmsController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @hcm.destroy

    respond_to do |format|
      format.html { redirect_to hcms_url, 
          notice: "#{@hcm.institution} was successfully destroyed." }
    end
  end

  #############################################################################
  ## set_hcm
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_hcm
    @hcm = Hcm.find(params[:id])
  end

  #############################################################################
  ## hcm_params
  ## Strong parameters
  #############################################################################  
  def hcm_params
    params.require(:hcm).permit(
      :institution, :ope, :hcm_type, :hcm_reason
    )
  end
end

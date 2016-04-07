class IpedsHdsController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_ipeds_hd, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @ipeds_hds = IpedsHd.paginate(:page => params[:page])
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
    @ipeds_hd = IpedsHd.new
        
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @ipeds_hd = IpedsHd.create(ipeds_hd_params)

    respond_to do |format|
      if @ipeds_hd.persisted?
        format.html { redirect_to @ipeds_hd, notice: "#{@ipeds_hd.cross} created."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @ipeds_hd.errors.full_messages
        flash.alert = IpedsHdsController.pretty_error(label, errors).html_safe

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
    rc = @ipeds_hd.update(ipeds_hd_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @ipeds_hd, notice: "#{@ipeds_hd.cross} updated."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @ipeds_hd.errors.full_messages
        flash.alert = IpedsHdsController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @ipeds_hd.destroy

    respond_to do |format|
      format.html { redirect_to ipeds_hds_url, 
          notice: "#{@ipeds_hd.cross} was successfully destroyed." }
    end
  end

  #############################################################################
  ## set_ipeds_hd
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_ipeds_hd
    @ipeds_hd = IpedsHd.find(params[:id])
  end

  #############################################################################
  ## ipeds_hd_params
  ## Strong parameters
  #############################################################################  
  def ipeds_hd_params
    params.require(:ipeds_hd).permit(
      :cross, :vet_tuition_policy_url
    )
  end
end


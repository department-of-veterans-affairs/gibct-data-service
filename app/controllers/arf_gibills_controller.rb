class ArfGibillsController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_arf_gibill, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @arf_gibills = ArfGibill.paginate(:page => params[:page])
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
    @arf_gibill = ArfGibill.new
        
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @arf_gibill = ArfGibill.create(arf_gibill_params)

    respond_to do |format|
      if @arf_gibill.persisted?
        format.html { redirect_to @arf_gibill, notice: "#{@arf_gibill.institution} created."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @arf_gibill.errors.full_messages
        flash.alert = ArfGibillsController.pretty_error(label, errors).html_safe

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
    rc = @arf_gibill.update(arf_gibill_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @arf_gibill, notice: "#{@arf_gibill.institution} updated."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @arf_gibill.errors.full_messages
        flash.alert = ArfGibillsController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @arf_gibill.destroy

    respond_to do |format|
      format.html { redirect_to arf_gibills_url, 
          notice: "#{@arf_gibill.institution} was successfully destroyed." }
    end
  end

  #############################################################################
  ## set_arf_gibill
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_arf_gibill
    @arf_gibill = ArfGibill.find(params[:id])
  end

  #############################################################################
  ## arf_gibill_params
  ## Strong parameters
  #############################################################################  
  def arf_gibill_params
    params.require(:arf_gibill).permit(
      :facility_code, :institution, :total_count_of_students
    )
  end
end

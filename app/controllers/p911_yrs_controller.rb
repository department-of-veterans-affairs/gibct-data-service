class P911YrsController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_p911_yr, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @p911_yrs = P911Yr.paginate(:page => params[:page])
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
    @p911_yr = P911Yr.new
        
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @p911_yr = P911Yr.create(p911_yr_params)

    respond_to do |format|
      if @p911_yr.persisted?
        format.html { redirect_to @p911_yr, notice: "#{@p911_yr.institution} created."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @p911_yr.errors.full_messages
        flash.alert = P911YrsController.pretty_error(label, errors).html_safe

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
    rc = @p911_yr.update(p911_yr_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @p911_yr, notice: "#{@p911_yr.institution} updated."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @p911_yr.errors.full_messages
        flash.alert = P911YrsController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @p911_yr.destroy

    respond_to do |format|
      format.html { redirect_to p911_yrs_url, 
          notice: "#{@p911_yr.institution} was successfully destroyed." }
    end
  end

  #############################################################################
  ## set_p911_yr
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_p911_yr
    @p911_yr = P911Yr.find(params[:id])
  end

  #############################################################################
  ## p911_yr_params
  ## Strong parameters
  #############################################################################  
  def p911_yr_params
    params.require(:p911_yr).permit(
      :facility_code, :institution, :p911_yellow_ribbon, :p911_yr_recipients
    )
  end
end

class Sec702SchoolsController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_sec702_school, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @sec702_schools = Sec702School.paginate(:page => params[:page])
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
    @sec702_school = Sec702School.new
        
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @sec702_school = Sec702School.create(sec702_school_params)

    respond_to do |format|
      if @sec702_school.persisted?
        format.html { redirect_to @sec702_school, notice: "#{@sec702_school.facility_code} created."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @sec702_school.errors.full_messages
        flash.alert = Sec702SchoolsController.pretty_error(label, errors).html_safe

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
    rc = @sec702_school.update(sec702_school_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @sec702_school, notice: "#{@sec702_school.facility_code} updated."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @sec702_school.errors.full_messages
        flash.alert = Sec702SchoolsController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @sec702_school.destroy

    respond_to do |format|
      format.html { redirect_to sec702_schools_url, 
          notice: "#{@sec702_school.facility_code} was successfully destroyed." }
    end
  end

  #############################################################################
  ## set_sec702_school
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_sec702_school
    @sec702_school = Sec702School.find(params[:id])
  end

  #############################################################################
  ## sec702_school_params
  ## Strong parameters
  #############################################################################  
  def sec702_school_params
    params.require(:sec702_school).permit(
      :facility_code, :sec_702
    )
  end
end


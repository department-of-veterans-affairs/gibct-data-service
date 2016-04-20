class AccreditationsController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_accreditation, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @accreditations = Accreditation.paginate(:page => params[:page])
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
    @accreditation = Accreditation.new
        
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @accreditation = Accreditation.create(accreditation_params)

    respond_to do |format|
      if @accreditation.persisted?
        format.html { redirect_to @accreditation, notice: "#{@accreditation.institution} created."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @accreditation.errors.full_messages
        flash.alert = AccreditationsController.pretty_error(label, errors).html_safe

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
    rc = @accreditation.update(accreditation_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @accreditation, notice: "#{@accreditation.institution} updated."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @accreditation.errors.full_messages
        flash.alert = AccreditationsController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @accreditation.destroy

    respond_to do |format|
      format.html { redirect_to accreditations_url, 
          notice: "#{@accreditation.institution} was successfully destroyed." }
    end
  end

  #############################################################################
  ## set_accreditation
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_accreditation
    @accreditation = Accreditation.find(params[:id])
  end

  #############################################################################
  ## accreditation_params
  ## Strong parameters
  #############################################################################  
  def accreditation_params
    params.require(:accreditation).permit(
      :institution_name, :ope, :institution_ipeds_unitid, :campus_name,
      :campus_ipeds_unitid, :agency_name, :accreditation_status, :periods,
      :csv_accreditation_type
    )
  end
end

class OutcomesController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_outcome, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @outcomes = Outcome.paginate(:page => params[:page])
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
    @outcome = Outcome.new
        
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @outcome = Outcome.create(outcome_params)

    respond_to do |format|
      if @outcome.persisted?
        format.html { redirect_to @outcome, notice: "#{@outcome.institution} created."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @outcome.errors.full_messages
        flash.alert = OutcomesController.pretty_error(label, errors).html_safe

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
    rc = @outcome.update(outcome_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @outcome, notice: "#{@outcome.institution} updated."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @outcome.errors.full_messages
        flash.alert = OutcomesController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @outcome.destroy

    respond_to do |format|
      format.html { redirect_to outcomes_url, 
          notice: "#{@outcome.institution} was successfully destroyed." }
    end
  end

  #############################################################################
  ## set_outcome
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_outcome
    @outcome = Outcome.find(params[:id])
  end

  #############################################################################
  ## outcome_params
  ## Strong parameters
  #############################################################################  
  def outcome_params
    params.require(:outcome).permit(
      :facility_code, :institution, 
      :retention_rate_veteran_ba, :retention_rate_veteran_otb, 
      :persistance_rate_veteran_ba, :persistance_rate_veteran_otb,
      :graduation_rate_veteran, :transfer_out_rate_veteran
    )
  end
end

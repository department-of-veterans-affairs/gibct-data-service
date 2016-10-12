class ScorecardsController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_scorecard, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @scorecards = Scorecard.paginate(:page => params[:page])
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
    @scorecard = Scorecard.new
        
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @scorecard = Scorecard.create(scorecard_params)

    respond_to do |format|
      if @scorecard.persisted?
        format.html { redirect_to @scorecard, notice: "#{@scorecard.institution} created."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @scorecard.errors.full_messages
        flash.alert = ScorecardsController.pretty_error(label, errors).html_safe

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
    rc = @scorecard.update(scorecard_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @scorecard, notice: "#{@scorecard.institution} updated."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @scorecard.errors.full_messages
        flash.alert = ScorecardsController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @scorecard.destroy

    respond_to do |format|
      format.html { redirect_to scorecards_url, 
          notice: "#{@scorecard.institution} was successfully destroyed." }
    end
  end

  #############################################################################
  ## set_scorecard
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_scorecard
    @scorecard = Scorecard.find(params[:id])
  end

  #############################################################################
  ## scorecard_params
  ## Strong parameters
  #############################################################################  
  def scorecard_params
    params.require(:scorecard).permit(
      :cross, :ope, :institution, :insturl, :pred_degree_awarded, :locale,
      :undergrad_enrollment, :retention_all_students_ba, 
      :retention_all_students_otb, :salary_all_students, 
      :repayment_rate_all_students, :avg_stu_loan_debt, :c150_4_pooled_supp, 
      :c150_l4_pooled_supp
    )
  end
end

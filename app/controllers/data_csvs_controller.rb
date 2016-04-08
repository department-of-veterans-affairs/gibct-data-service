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
      :non_college_degree_indicator, :ope, :cross, :student_veteran,
      :student_veteran_link, :vetsuccess_name, :vetsuccess_email, :eight_keys,
      :accreditation_status, :accreditation_type, :gibill, :p911_tuition_fees,
      :p911_recipients, :p911_yellow_ribbon, :p911_yr_recipients, :dodmou,
      :insturl, :pred_degree_awarded, :locale, :undergrad_enrollment,
      :retention_all_students_ba, :retention_all_students_otb,
      :graduation_rate_all_students, :transfer_out_rate_all_students,
      :salary_all_students, :repayment_rate_all_students, :avg_stu_loan_debt,
      :credit_for_mil_training, :vet_poc, :student_vet_grp_ipeds, :soc_member,
      :calendar, :online_all, :vet_tuition_policy_url, :tuition_in_state, 
      :tuition_out_of_state, :books, :sec_702
    )
  end
end

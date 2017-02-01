class ComplaintsController < ApplicationController
  include Alertable

  before_action :authenticate_user!
  before_action :set_complaint, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @complaints = Complaint.paginate(page: params[:page])
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
    @complaint = Complaint.new

    respond_to do |format|
      format.html
    end
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @complaint = Complaint.create(complaint_params)

    respond_to do |format|
      if @complaint.persisted?
        format.html { redirect_to @complaint, notice: "#{@complaint.institution} created." }
      else
        label = 'Errors prohibited this file from being saved:'
        errors = @complaint.errors.full_messages
        flash.alert = ComplaintsController.pretty_error(label, errors).html_safe

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
    rc = @complaint.update(complaint_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @complaint, notice: "#{@complaint.institution} updated." }
      else
        label = 'Errors prohibited this file from being saved:'
        errors = @complaint.errors.full_messages
        flash.alert = ComplaintsController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @complaint.destroy

    respond_to do |format|
      format.html do
        redirect_to complaints_url,
                    notice: "#{@complaint.institution} was successfully destroyed."
      end
    end
  end

  #############################################################################
  ## set_complaint
  ## Obtains the model instance from the id parameter.
  #############################################################################
  def set_complaint
    @complaint = Complaint.find(params[:id])
  end

  #############################################################################
  ## complaint_params
  ## Strong parameters
  #############################################################################
  def complaint_params
    params.require(:complaint).permit(
      :facility_code, :ope, :institution, :status,
      :closed_reason, :issue
    )
  end
end

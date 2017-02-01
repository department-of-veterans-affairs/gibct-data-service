class IpedsIcsController < ApplicationController
  include Alertable

  before_action :authenticate_user!
  before_action :set_ipeds_ic, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @ipeds_ics = IpedsIc.paginate(page: params[:page])
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
    @ipeds_ic = IpedsIc.new

    respond_to do |format|
      format.html
    end
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @ipeds_ic = IpedsIc.create(ipeds_ic_params)

    respond_to do |format|
      if @ipeds_ic.persisted?
        format.html { redirect_to @ipeds_ic, notice: "#{@ipeds_ic.cross} created." }
      else
        label = 'Errors prohibited this file from being saved:'
        errors = @ipeds_ic.errors.full_messages
        flash.alert = IpedsIcsController.pretty_error(label, errors).html_safe

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
    rc = @ipeds_ic.update(ipeds_ic_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @ipeds_ic, notice: "#{@ipeds_ic.cross} updated." }
      else
        label = 'Errors prohibited this file from being saved:'
        errors = @ipeds_ic.errors.full_messages
        flash.alert = IpedsIcsController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @ipeds_ic.destroy

    respond_to do |format|
      format.html do
        redirect_to ipeds_ics_url,
                    notice: "#{@ipeds_ic.cross} was successfully destroyed."
      end
    end
  end

  #############################################################################
  ## set_ipeds_ic
  ## Obtains the model instance from the id parameter.
  #############################################################################
  def set_ipeds_ic
    @ipeds_ic = IpedsIc.find(params[:id])
  end

  #############################################################################
  ## ipeds_ic_params
  ## Strong parameters
  #############################################################################
  def ipeds_ic_params
    params.require(:ipeds_ic).permit(
      :cross, :vet2, :vet3, :vet4, :vet5, :calsys, :distnced
    )
  end
end

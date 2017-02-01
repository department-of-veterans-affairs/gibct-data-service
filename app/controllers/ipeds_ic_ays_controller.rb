class IpedsIcAysController < ApplicationController
  include Alertable

  before_action :authenticate_user!
  before_action :set_ipeds_ic_ay, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @ipeds_ic_ays = IpedsIcAy.paginate(page: params[:page])
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
    @ipeds_ic_ay = IpedsIcAy.new

    respond_to do |format|
      format.html
    end
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @ipeds_ic_ay = IpedsIcAy.create(ipeds_ic_ay_params)

    respond_to do |format|
      if @ipeds_ic_ay.persisted?
        format.html { redirect_to @ipeds_ic_ay, notice: "#{@ipeds_ic_ay.cross} created." }
      else
        label = 'Errors prohibited this file from being saved:'
        errors = @ipeds_ic_ay.errors.full_messages
        flash.alert = IpedsIcAysController.pretty_error(label, errors).html_safe

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
    rc = @ipeds_ic_ay.update(ipeds_ic_ay_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @ipeds_ic_ay, notice: "#{@ipeds_ic_ay.cross} updated." }
      else
        label = 'Errors prohibited this file from being saved:'
        errors = @ipeds_ic_ay.errors.full_messages
        flash.alert = IpedsIcAysController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @ipeds_ic_ay.destroy

    respond_to do |format|
      format.html do
        redirect_to ipeds_ic_ays_url,
                    notice: "#{@ipeds_ic_ay.cross} was successfully destroyed."
      end
    end
  end

  #############################################################################
  ## set_ipeds_ic
  ## Obtains the model instance from the id parameter.
  #############################################################################
  def set_ipeds_ic_ay
    @ipeds_ic_ay = IpedsIcAy.find(params[:id])
  end

  #############################################################################
  ## ipeds_ic_params
  ## Strong parameters
  #############################################################################
  def ipeds_ic_ay_params
    params.require(:ipeds_ic_ay).permit(
      :cross, :tuition_in_state, :tuition_out_of_state, :books
    )
  end
end

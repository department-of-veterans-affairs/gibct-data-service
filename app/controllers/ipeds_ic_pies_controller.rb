class IpedsIcPiesController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_ipeds_ic_py, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @ipeds_ic_pys = IpedsIcPy.paginate(:page => params[:page])
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
    @ipeds_ic_py = IpedsIcPy.new
        
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @ipeds_ic_py = IpedsIcPy.create(ipeds_ic_py_params)

    respond_to do |format|
      if @ipeds_ic_py.persisted?
        format.html { redirect_to @ipeds_ic_py, notice: "#{@ipeds_ic_py.cross} created."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @ipeds_ic_py.errors.full_messages
        flash.alert = IpedsIcPiesController.pretty_error(label, errors).html_safe

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
    rc = @ipeds_ic_py.update(ipeds_ic_py_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @ipeds_ic_py, notice: "#{@ipeds_ic_py.cross} updated."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @ipeds_ic_py.errors.full_messages
        flash.alert = IpedsIcPiesController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @ipeds_ic_py.destroy

    respond_to do |format|
      format.html { redirect_to ipeds_ic_pies_url, 
          notice: "#{@ipeds_ic_py.cross} was successfully destroyed." }
    end
  end

  #############################################################################
  ## set_ipeds_ic
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_ipeds_ic_py
    @ipeds_ic_py = IpedsIcPy.find(params[:id])
  end

  #############################################################################
  ## ipeds_ic_params
  ## Strong parameters
  #############################################################################  
  def ipeds_ic_py_params
    params.require(:ipeds_ic_py).permit(
      :cross, :chg1py3, :chg5py3
    )
  end
end

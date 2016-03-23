class SvasController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_sva, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @svas = Sva.paginate(:page => params[:page])
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
    @sva = Sva.new
        
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @sva = Sva.create(sva_params)
    respond_to do |format|
      if @sva.persisted?
        format.html { redirect_to @sva, notice: "#{@sva.institution} created."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @sva.errors.full_messages
        flash.alert = SvasController.pretty_error(label, errors).html_safe

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
    rc = @sva.update(sva_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @sva, notice: "#{@sva.institution} updated."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @sva.errors.full_messages
        flash.alert = SvasController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @sva.destroy

    respond_to do |format|
      format.html { redirect_to svas_url, 
          notice: "#{@sva.institution} was successfully destroyed." }
    end
  end

  #############################################################################
  ## set_sva
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_sva
    @sva = Sva.find(params[:id])
  end

  #############################################################################
  ## csv_file_params
  ## Strong parameters
  #############################################################################  
  def sva_params
    params.require(:sva).permit(
      :institution, :cross, :city, :state, :student_veteran_link
    )
  end
end

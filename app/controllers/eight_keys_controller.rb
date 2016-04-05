class EightKeysController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_eight_key, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @eight_keys = EightKey.paginate(:page => params[:page])
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
    @eight_key = EightKey.new
        
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @eight_key = EightKey.create(eight_key_params)

    respond_to do |format|
      if @eight_key.persisted?
        format.html { redirect_to @eight_key, notice: "#{@eight_key.institution} created."}
      else
        label = "Errors eight_key this file from being saved:"
        errors = @eight_key.errors.full_messages
        flash.alert = EightKeysController.pretty_error(label, errors).html_safe

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
    rc = @eight_key.update(eight_key_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @eight_key, notice: "#{@eight_key.institution} updated."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @eight_key.errors.full_messages
        flash.alert = EightKeysController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @eight_key.destroy

    respond_to do |format|
      format.html { redirect_to eight_keys_url, 
          notice: "#{@eight_key.institution} was successfully destroyed." }
    end
  end

  #############################################################################
  ## set_eight_key
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_eight_key
    @eight_key = EightKey.find(params[:id])
  end

  #############################################################################
  ## eight_key_params
  ## Strong parameters
  #############################################################################  
  def eight_key_params
    params.require(:eight_key).permit(
      :institution, :ope, :cross
    )
  end
end

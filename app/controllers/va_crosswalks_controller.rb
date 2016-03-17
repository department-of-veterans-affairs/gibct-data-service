class VaCrosswalksController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_va_crosswalk, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @va_crosswalks = VaCrosswalk.paginate(:page => params[:page])
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
  ## set_va_crosswalk
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_va_crosswalk
    @va_crosswalk = VaCrosswalk.find(params[:id])
  end

  #############################################################################
  ## csv_file_params
  ## Strong parameters
  #############################################################################  
  def va_crosswalk_params
    params.require(:va_crosswalk).permit(
      :facility_code, :institution, :city, :state, :ope, :cross, :notes
    )
  end
end

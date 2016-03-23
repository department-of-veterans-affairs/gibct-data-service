class Sec702sController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_sec702, only: [:show, :edit, :destroy, :update]

  #############################################################################
  ## index
  #############################################################################
  def index
    @sec702s = Sec702.paginate(:page => params[:page])
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
    @sec702 = Sec702.new
        
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @sec702 = Sec702.create(sec702_params)

    respond_to do |format|
      if @sec702.persisted?
        format.html { redirect_to @sec702, notice: "#{@sec702.state} created."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @sec702.errors.full_messages
        flash.alert = Sec702sController.pretty_error(label, errors).html_safe

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
    rc = @sec702.update(sec702_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @sec702, notice: "#{@sec702.state} updated."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @sec702.errors.full_messages
        flash.alert = Sec702sController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @sec702.destroy

    respond_to do |format|
      format.html { redirect_to sec702s_url, 
          notice: "#{@sec702.state} was successfully destroyed." }
    end
  end

  #############################################################################
  ## set_sec702
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_sec702
    @sec702 = Sec702.find(params[:id])
  end

  #############################################################################
  ## csv_file_params
  ## Strong parameters
  #############################################################################  
  def sec702_params
    params.require(:sec702).permit(
      :state, :sec_702
    )
  end
end

class WeamsController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  before_action :set_weam, only: [:show, :edit, :destroy, :update]

	#############################################################################
  ## index
  #############################################################################
  def index
		@weams = Weam.paginate(:page => params[:page])
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
    @weam = Weam.new
        
    respond_to do |format|
      format.html
    end 
  end

  #############################################################################
  ## create
  #############################################################################
  def create
    @weam = Weam.create(weam_params)

    respond_to do |format|
      if @weam.persisted?
        format.html { redirect_to @weam, notice: "#{@weam.institution} created."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @weam.errors.full_messages
        flash.alert = WeamsController.pretty_error(label, errors).html_safe

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
    rc = @weam.update(weam_params)

    respond_to do |format|
      if rc != false
        format.html { redirect_to @weam, notice: "#{@weam.institution} updated."}
      else
        label = "Errors prohibited this file from being saved:"
        errors = @weam.errors.full_messages
        flash.alert = WeamsController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  def destroy
    @weam.destroy

    respond_to do |format|
      format.html { redirect_to weams_url, 
          notice: "#{@weam.institution} was successfully destroyed." }
    end
  end

  #############################################################################
  ## set_weam
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_weam
  	@weam = Weam.find(params[:id])
  end

  #############################################################################
  ## csv_file_params
  ## Strong parameters
  #############################################################################  
  def weam_params
    params.require(:weam).permit(
    	:facility_code, :institution, :type, :city, :state, :zip, :country, :bah,
    	:accredited, :poe, :yr, :ojt_indicator, :correspondence_indicator,
    	:flight_indicator
    )
  end
end

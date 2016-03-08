class RawFileSourcesController < ApplicationController
	include Alertable

	before_action :authenticate_user! 
	before_action :set_source, only: [:show, :edit, :update, :destroy]

	def index
		@raw_file_sources = RawFileSource.all.order(:build_order)

		respond_to do |format|
			format.html
		end
	end

	def new
		@raw_file_source = RawFileSource.new
		
		respond_to do |format|
			format.html
		end	
	end

	def show
		respond_to do |format|
			format.html
		end	
	end

	def create
		@raw_file_source = RawFileSource.new(source_params)
		saved = true

		begin
			RawFileSource.transaction do
				@raw_file_source.save!
				@csv_file = @raw_file_source.create_csv_file!(data: 0)
			end
		rescue StandardError => e 
			saved = false
		end

		respond_to do |format|
			if saved
				format.html { redirect_to @raw_file_source, notice: "#{@raw_file_source.name} saved."}
			else
      	label = "Errors prohibited this source from being saved:"
      	errors = @raw_file_source.try(:errors).try(:full_messages) || []
				errors += @csv_file.try(:errors).try(:full_messages) || []

				flash.alert = RawFileSourcesController.pretty_error(label, errors).html_safe
        format.html { render :new }
 			end
		end
	end

	def edit
		respond_to do |format|
			format.html
		end	
	end

	def update
    respond_to do |format|
      if @raw_file_source.update(source_params)
        format.html { redirect_to @raw_file_source, notice: "#{@raw_file_source.name} updated." }
      else
      	label = "Errors prohibited this source from being saved:"
      	errors = @raw_file_source.errors.full_messages
				flash.alert = RawFileSourcesController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  def destroy
		@raw_file_source.destroy

    respond_to do |format|
      format.html { redirect_to raw_file_sources_url, 
      	notice: "#{@raw_file_source.name} was successfully destroyed." }
    end
  end

  private
  #############################################################################
  ## set_source
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_source
  	@raw_file_source = RawFileSource.includes(:raw_files).find(params[:id])
  end

  #############################################################################
  ## source_params
  ## Strong parameters
  #############################################################################  
  def source_params
    params.require(:raw_file_source).permit(:name, :build_order)
  end
end

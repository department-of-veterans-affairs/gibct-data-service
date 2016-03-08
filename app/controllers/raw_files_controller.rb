class RawFilesController < ApplicationController
	include Alertable

	before_action :authenticate_user! 
	before_action :set_file, only: [:show, :edit, :update, :destroy, :send_csv_file]

	def index
		@raw_files = RawFile.all.order(:upload_date, :type)

		respond_to do |format|
			format.html
		end
	end

	def new
		@raw_file = RawFile.new
				
		respond_to do |format|
			format.html
		end	
	end

	def create
		begin
			@raw_file = Object::const_get(params[:raw_file][:type]).new()
		rescue StandardError => e 
			object_error = e.message
		end

		respond_to do |format|
			if object_error.blank? && create_raw_file_record_and_upload
				format.html { redirect_to @raw_file, notice: "#{@raw_file.name} saved."}
			else
				@raw_file = RawFile.new if @raw_file.nil?

      	label = "Errors prohibited this file from being saved:"
      	errors = @raw_file.errors.full_messages
      	errors << object_error if object_error.present?

				flash.alert = RawFilesController.pretty_error(label, errors).html_safe

        format.html { render :new }
 			end
		end
	end

	def show
		respond_to do |format|
			format.html
		end	
	end

	def edit
		respond_to do |format|
			format.html
		end	
	end

	def update
		@raw_file.type = params[:raw_file][:type]

    respond_to do |format|
      if create_raw_file_record_and_upload
				format.html { redirect_to @raw_file, notice: "#{@raw_file.name} saved."}
      else
      	label = "Errors prohibited this raw file from being saved:"
      	errors = @raw_file.errors.full_messages
				flash.alert = RawFilesController.pretty_error(label, errors).html_safe

        format.html { render :edit }
      end
    end
  end

  def destroy
		if @raw_file.latest?
			@raw_file.raw_file_source.csv_file.data = "0"  	
			@raw_file.raw_file_source.csv_file.save!
		end

		@raw_file.destroy

    respond_to do |format|
     	format.html { redirect_to raw_files_url, 
      		notice: "#{@raw_file.name} was successfully destroyed." }
    end
  end

	def send_csv_file
		if @raw_file.raw_file_source.present?
			send_data(@raw_file.raw_file_source.csv_file.data) 
		end
	end

  private  
  #############################################################################
  ## create_raw_file_record_and_upload
  ## Creates and uploads a raw file, but only if both the upload is successful
  ## and the raw file valid.
  #############################################################################
  def create_raw_file_record_and_upload
  	source_name = @raw_file.class_to_source
		@raw_file.raw_file_source = RawFileSource.find_by(name: source_name)
		@raw_file.upload_date = DateTime.current
		@raw_file.name = @raw_file.to_server_name

		if completed = @raw_file.valid? && @raw_file.raw_file_source.present?
			ActiveRecord::Base.transaction do
				completed = upload_file(params[:raw_file][:upload]) && @raw_file.save!
			end
		end

		completed
  end

  #############################################################################
  ## set_file
  ## Obtains the model instance from the id parameter.
  #############################################################################  
  def set_file
  	@raw_file = RawFile.find(params[:id])
  end

  #############################################################################
  ## upload_file
  ## Uploads the given file, and removes the previous file (of the same raw
  ## file type).
  #############################################################################  
  def upload_file(uploaded_file)
  	csv_file = @raw_file.raw_file_source.csv_file

		begin
			raise StandardError.new("File upload object is nil") if uploaded_file.nil?

			old_logger = ActiveRecord::Base.logger
			ActiveRecord::Base.logger = nil

			csv_file.data = uploaded_file.read
			csv_file.save!
			rc = true
  	rescue StandardError => e
  		@raw_file.errors[:base] << e.message
  		rc = false
  	ensure
			ActiveRecord::Base.logger = old_logger  		
 		end

 		return rc
  end
end

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
		@raw_file = Object::const_get(params[:raw_file][:type]).new()
		source_name = @raw_file.class_to_source

		@raw_file.raw_file_source = RawFileSource.find_by(name: source_name)
		@raw_file.upload_date = DateTime.current
		@raw_file.name = @raw_file.to_server_name

		upload_file

		saved = @raw_file.save

		respond_to do |format|
			if saved
				format.html { redirect_to @raw_file, notice: "#{@raw_file.name} saved."}
			else
      	label = "Errors prohibited this file from being saved:"
      	errors = @raw_file.errors.full_messages
				flash.alert = FileSourcesController.pretty_error(label, errors).html_safe

        format.html { render :new }
 			end
		end
	end

	def show
		@csv = Rails.root.join('data', @raw_file.name)

		respond_to do |format|
			format.html
		end	
	end

	def send_csv_file
		path = Rails.root.join('data', @raw_file.name)
		send_file(path, filename: @raw_file.name)
	end

  private
  def set_file
  	@raw_file = RawFile.find(params[:id])
  end

  def upload_file
  	upload = params[:raw_file][:upload]

		if last_file = RawFile.where(type: @raw_file.type).order(:upload_date).last
			last_file_name = Rails.root.join('data', last_file.name)

			File.delete(last_file_name) if File.exist?(last_file_name)
		end
		
		csv = Rails.root.join('data', @raw_file.name)
  	File.open(csv, 'wb') do |file|
    	file.write(upload.read)
 		end
  end
end

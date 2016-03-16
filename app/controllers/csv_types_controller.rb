class CsvTypesController < ApplicationController
  include Alertable

  before_action :authenticate_user! 
  
  #############################################################################
  ## index
  #############################################################################
  def index
  	@csv_types = CsvFile.types

  	respond_to do |format|
			format.html
		end
  end

  #############################################################################
  ## show
  ## Displays a csv file type (weams, crosswalk, etc) along with the upload
  ## records for the file of this type.
  #############################################################################
  def show
  	@csv_type = params[:id]
  	@csv_files = CsvFile.where(type: @csv_type)
    @last_csv = @csv_files.last_upload
    @humanized_csv_type = @csv_type.underscore.split('_').map(&:capitalize).join(' ')

  	respond_to do |format|
			format.html
		end
  end
end

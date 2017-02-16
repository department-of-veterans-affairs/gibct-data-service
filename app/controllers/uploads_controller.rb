class UploadsController < ApplicationController
  def index
    @uploads = Upload.order(:created_at)

    respond_to do |format|
      format.html
    end
  end
end

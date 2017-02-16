# frozen_string_literal: true
class UploadsController < ApplicationController
  def index
    @uploads = Upload.paginate(page: params[:page]).order(:created_at)

    respond_to do |format|
      format.html
    end
  end
end

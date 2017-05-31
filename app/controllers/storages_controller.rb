# frozen_string_literal: true
class StoragesController < ApplicationController
  def index
    @storages = Storage.all
  end

  def download
    @storage = Storage.find_by(id: params[:id])
    raise(ArgumentError, "Invalid Storage id: #{params[:id]}") if @storage.blank?

    respond_to do |format|
      format.csv { send_data @storage.data, type: 'text/csv', filename: @storage.csv }
    end
  rescue ArgumentError, ActionController::UnknownFormat => e
    Rails.logger.error e.message
    redirect_to storages_path, alert: e.message
  end
end

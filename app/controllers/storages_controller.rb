# frozen_string_literal: true
class StoragesController < ApplicationController
  def index
    @storages = Storage.all
  end

  def show
    @storage = find_storage
  rescue ArgumentError, ActionController::UnknownFormat => e
    Rails.logger.error e.message
    redirect_to storages_path, alert: e.message
  end

  def edit
    @storage = find_storage
  rescue ArgumentError, ActionController::UnknownFormat => e
    Rails.logger.error e.message
    redirect_to storages_path, alert: e.message
  end

  def update
    @storage = Storage.find_and_update(merged_params)
    raise StandardError, @storage.errors.full_messages unless @storage.valid?
    redirect_to storage_path(params[:id])
  rescue StandardError => e
    Rails.logger.error e.message
    redirect_to edit_storage_path, alert: e.message
  end

  def download
    @storage = find_storage

    respond_to do |format|
      format.csv { send_data @storage.data, type: 'text/csv', filename: @storage.csv }
    end
  rescue ArgumentError, ActionController::UnknownFormat => e
    Rails.logger.error e.message
    redirect_to storages_path, alert: e.message
  end

  private

  def original_filename
    @f ||= upload_params.try(:[], :upload_file)&.original_filename
  end

  def merged_params
    upload_params.merge(csv: original_filename, user: current_user, id: params[:id])
  end

  def upload_params
    @u ||= params.require(:storage).permit(:upload_file, :comment)
  end

  def find_storage
    storage = Storage.find_by(id: params[:id])
    raise(ArgumentError, "Invalid Storage id: #{params[:id]}") if storage.blank?

    storage
  end
end

# frozen_string_literal: true

class ArchivesController < ApplicationController
  before_action :flash_preview_status, only: :index
  
  TABLES = [
    InstitutionsArchive
  ].freeze

  # GET /archives
  def index
    @archive_versions = Version.archived
  end

  def export
    respond_to do |format|
      format.csv do
        send_data csv_model(params[:csv_type]).export_by_version(export_all: true),
                  type: 'text/csv',
                  filename: "#{params[:csv_type]}_version_#{params[:number]}.csv"
      end
    end
  rescue ArgumentError, Common::Exceptions::Internal::RecordNotFound, ActionController::UnknownFormat, MissingAttributeError => e
    Rails.logger.error e.message
    redirect_to archives_path, alert: e.message
  end

  def csv_model(csv_type)
    model = TABLES.find { |klass| klass.name == csv_type }
    return model if model.present?

    raise(ArgumentError, "#{csv_type} is not a valid Archive CSV type")
  end
end

# frozen_string_literal: true

class ArchivesController < ApplicationController
  TABLES = [
    InstitutionsArchive
  ].freeze

  # GET /archives
  def index
    @archive_versions = Version.archived
  end

  def export
    klass = csv_model(params[:csv_type])
    version = params[:version]

    respond_to do |format|
      format.csv { send_data klass.export_archive(version), type: 'text/csv', filename: "#{klass.name}_#{version}.csv" }
    end
    # rescue ArgumentError, ActionController::UnknownFormat => e
    #   Rails.logger.error e.message
    #   redirect_to archives_path, alert: e.message
  end

  def csv_model(csv_type)
    model = TABLES.select { |klass| klass.name == csv_type }.first
    return model if model.present?

    raise(ArgumentError, "#{csv_type} is not a valid Archive CSV type") if model.blank?
  end
end

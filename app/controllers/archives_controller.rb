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
    respond_to do |format|
      format.csv do
        send_data InstitutionsArchive.export_institutions_by_version(params[:number]),
                  type: 'text/csv',
                  filename: "institutions_version_#{params[:number]}.csv"
      end
    end
  rescue ArgumentError, Common::Exceptions::RecordNotFound, ActionController::UnknownFormat => e
    Rails.logger.error e.message
    redirect_to archives_path, alert: e.message
  end

  def csv_model(csv_type)
    model = TABLES.select { |klass| klass.name == csv_type }.first
    return model if model.present?

    raise(ArgumentError, "#{csv_type} is not a valid Archive CSV type") if model.blank?
  end
end

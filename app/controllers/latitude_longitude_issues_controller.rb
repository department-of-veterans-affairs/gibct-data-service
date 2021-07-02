# frozen_string_literal: true

class LatitudeLongitudeIssuesController < ApplicationController
  def export
    send_data CensusLatLong.export, type: 'application/zip', filename: "#{CensusLatLong.name}.zip"
  rescue StandardError => e
    log_error(e)
  end

  def import
    @census_lat_long = CensusLatLong.new
    @extensions = Settings.roo_upload.extensions.single.join(', ')
  end

  def update
    csv_results = []
    file_options = { skip_loading: true }

    CensusLatLong.delete_all

    params[:uploaded_files].each do |file|
      csv_results << CensusLatLong.load_with_roo(file, file_options)
    end

    redirect_to dashboards_path
  end

  private

  def log_error(error)
    Rails.logger.error error.message + error.backtrace.to_s
    redirect_to dashboards_path, alert: "#{error.message}\n#{error.backtrace[0]}"
  end
end

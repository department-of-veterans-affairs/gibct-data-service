# frozen_string_literal: true

class LatitudeLongitudeIssuesController < ApplicationController
  def export
    send_data CensusLatLong.export, type: 'application/zip', filename: "#{CensusLatLong.name}.zip"
  rescue StandardError => e
    log_error(e)
  end

  def new
    @upload = Upload.from_csv_type(CensusLatLong.name)
    @extensions = Settings.roo_upload.extensions.single.join(', ')
    csv_requirements
  end

  def create
    csv_results = []
    file_options = { skip_loading: true }

    CensusLatLong.delete_all

    params[:uploaded_files].each do |file|
      csv_results << CensusLatLong.load_with_roo(file, file_options)
    end

    redirect_to dashboards_path
  end

  private

  def csv_requirements
    @requirements = [RooHelper.valid_col_seps] + UploadRequirements.requirements_messages(CensusLatLong)
    @custom_batch_validator = "#{CensusLatLong.name}Validator::REQUIREMENT_DESCRIPTIONS".safe_constantize
    @inclusion = UploadRequirements.validation_messages_inclusion(CensusLatLong)
  end

  def log_error(error)
    Rails.logger.error error.message + error.backtrace.to_s
    redirect_to dashboards_path, alert: "#{error.message}\n#{error.backtrace[0]}"
  end
end

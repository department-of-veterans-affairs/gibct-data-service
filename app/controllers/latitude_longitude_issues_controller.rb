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
    @upload = Upload.create(merged_params)
    begin
      CensusLatLong.delete_all
      data = CensusLatLong.load_multiple_files(merged_params[:upload_files], CensusLatLong)

      redirect_to dashboards_path
    rescue StandardError => e
      @upload = Upload.from_csv_type(CensusLatLong.name)
      @extensions = Settings.roo_upload.extensions.single.join(', ')
      csv_requirements
      alert_and_log("Failed to upload #{original_filenames} : #{e.message}\n#{e.backtrace[0]}", e)
      render :new
    end
  end

  private

  def original_filenames
    upload_params[:upload_files].map(&:original_filename).join(' , ')
  end

  def merged_params
    upload_params.merge(csv: original_filenames, user: current_user)
  end

  def upload_params
    @upload_params ||= params.require(:upload).permit(:csv_type, :comment, upload_files: [])
  end

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

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
      data = CensusLatLong.load_multiple_files(merged_params[:upload_files], CensusLatLong)
      not_ok = alert_messages(data)

      @upload.update(ok: not_ok.empty?, completed_at: Time.now.utc.to_s(:db))

      # only grab not_ok files names
      files = not_ok.map{|i| @upload.csv.split(' , ')[i]}.join(' , ')
      error_msg = "There was no saved #{CensusLatLong.name} data. Please check the file(s): #{files}."
      raise(StandardError, error_msg) unless @upload.ok?

      redirect_to action: 'show', id: @upload.id
    rescue StandardError => e
      @upload = Upload.from_csv_type(CensusLatLong.name)
      @extensions = Settings.roo_upload.extensions.single.join(', ')
      csv_requirements
      alert_and_log("Failed to upload #{original_filenames} : #{e.message}\n#{e.backtrace[0]}", e)
      render :new
    end
  end

  def show
    @upload = Upload.find_by(id: params[:id])

    csv_requirements if @upload.present?
    return if @upload.present?

    alert_and_log("Upload with id: '#{params[:id]}' not found")
    redirect_to uploads_path
  end

  private

  # Loop through each file's array of sheets to create messages for user and check if each file is consider ok
  def alert_messages(data)
    not_ok = []
    flash[:csv_success] = []
    flash[:warning] = []
    data.each_with_index do |file_results, index|
      file_results.each do |data|
        file_messages(data)
        not_ok << index unless data[:results].present? && data[:results].ids.present?
      end
    end
    not_ok.uniq
  end

  def file_messages(data)
    results = data[:results]

    total_rows_count = results.ids.length
    failed_rows = results.failed_instances
    failed_rows_count = failed_rows.length
    valid_rows = total_rows_count - failed_rows_count
    validation_warnings = failed_rows.sort { |a, b| a.errors[:row].first.to_i <=> b.errors[:row].first.to_i }
                                     .map(&:display_errors_with_row)

    if valid_rows.positive?
      flash[:csv_success] << {
        total_rows_count: total_rows_count.to_s,
        valid_rows: valid_rows.to_s,
        failed_rows_count: failed_rows_count.to_s
      }.compact
    end

    unless validation_warnings.empty?
      flash[:warning] << {
        'The following rows should be checked: ': validation_warnings
      }
    end
  end

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

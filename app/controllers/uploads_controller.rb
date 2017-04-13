# frozen_string_literal: true
class UploadsController < ApplicationController
  include Flashable

  VALID_CSVS = InstitutionBuilder::TABLES.map(&:name)

  def index
    @uploads = Upload.paginate(page: params[:page]).order(created_at: :desc)
  end

  def new
    @upload = new_upload(params[:csv_type])
    return if @upload.csv_type_check?

    msgs = params[:csv_type].blank? ? ['No Csv type was specified'] : @upload.errors.full_messages

    add_alerts('Error specifying Csv type: ', msgs)
    set_flash

    redirect_to dashboards_path
  end

  def create
    @upload = Upload.create(merged_params)

    begin
      results = load_csv

      failed = errors_for_alert(results[:data].failed_instances)
      diff_headers = results[:diffed_headers]

      add_notices("The upload of #{@upload.csv_type} succeeded.", [])
      add_notices('But following rows should be checked: ', failed) unless failed.empty?
      add_notices('The following headers were missing: ', diff_headers[:missing]) unless diff_headers[:missing].empty?
      add_notices('The following headers are extra: ', diff_headers[:extra]) unless diff_headers[:extra].empty?

      set_flash
      redirect_to @upload
    rescue StandardError => e
      add_alerts("Failed to upload #{original_filename}.", [e.message], e.backtrace)
      @upload = new_upload(merged_params[:csv_type])

      set_flash
      render :new
    end
  end

  def show
    @upload = Upload.find_by(id: params[:id])
    return if @upload.present?

    add_alerts('Could not display upload: ', ["Upload with id: '#{params[:id]}' not found"])
    set_flash

    redirect_to uploads_path
  end

  private

  def new_upload(csv_type)
    upload = Upload.new(csv_type: csv_type)
    upload.skip_lines = defaults(csv_type)['skip_lines']

    upload
  end

  def load_csv
    return unless @upload.persisted?
    call_load
  end

  def original_filename
    @f ||= upload_params[:upload_file].try(:original_filename)
  end

  def defaults(csv_type)
    Rails.application.config.csv_defaults[csv_type] || Rails.application.config.csv_defaults['generic']
  end

  def merged_params
    upload_params.merge(csv: original_filename, user: current_user)
  end

  def upload_params
    @u ||= params.require(:upload).permit(:csv_type, :skip_lines, :upload_file, :comment)
  end

  def call_load
    file = @upload.upload_file.tempfile
    skip_lines = @upload.skip_lines.try(:to_i)
    data = klass.load(file, skip_lines: skip_lines)

    @upload.update(ok: data.present? && data.ids.present?)
    raise(StandardError, "There was no saved #{klass} data!") unless @upload.ok?

    { data: data, diffed_headers: diffed_headers(file, skip_lines) }
  end

  def diffed_headers(file, skip_lines)
    file = @upload.upload_file.tempfile
    skip_lines = @upload.skip_lines.try(:to_i)
    model_headers = klass::CSV_CONVERTER_INFO.keys
    file_headers = csv_file_headers(file, skip_lines)

    { missing: model_headers - file_headers, extra: file_headers - model_headers }
  end

  def csv_file_headers(file, skip_lines)
    csv = CSV.open(file, return_headers: true, encoding: 'ISO-8859-1')
    skip_lines.times { csv.readline }

    (csv.readline || []).select(&:present?).map { |header| header.downcase.strip }
  end

  def klass
    @upload.csv_type.constantize
  end
end

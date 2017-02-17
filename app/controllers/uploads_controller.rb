# frozen_string_literal: true
class UploadsController < ApplicationController
  def index
    @uploads = Upload.paginate(page: params[:page]).order(:created_at)

    respond_to do |format|
      format.html
    end
  end

  def new
    csv_type = params[:csv_type]

    @upload = Upload.new(csv_type: csv_type)
    @upload.skip_lines = defaults[csv_type || 'generic']['skip_lines']

    respond_to do |format|
      format.html
    end
  end

  private

  def defaults
    @defaults ||= YAML.load_file(Rails.root.join('config', 'csv_file_defaults.yml'))
  end

  def upload_parameters; end
end

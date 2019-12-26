# frozen_string_literal: true

class ApiFetchController < ApplicationController

  def index
    @upload = Upload.from(params[:csv_type])
    redirect_to dashboards_path if @upload.csv_type_check?

  rescue StandardError => e
    Rails.logger.error e.message
    redirect_to dashboards_path, alert: e.message
  end
end
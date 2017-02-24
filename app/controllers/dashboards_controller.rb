# frozen_string_literal: true
class DashboardsController < ApplicationController
  include Flashable

  def index
    @uploads = Upload.last_uploads
  end

  def build
    @version = InstitutionBuilder.run(current_user)
  end

  def export
    klass = csv_model(params[:csv_type])
    csv_data = klass.export
    raise StandardError, 'No data to export.' if csv_data.blank?

    respond_to do |format|
      format.csv { send_data csv_data, type: 'text/csv' }
    end
  rescue StandardError => e
    redirect_to dashboards_path, alert: e.message
  end

  private

  def csv_model(csv_type)
    InstitutionBuilder::TABLES.select { |model| model.name == csv_type }.first
  end
end

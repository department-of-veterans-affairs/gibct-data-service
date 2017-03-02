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

  def push
    version = Version.preview_version

    if version.nil?
      flash.alert = 'No preview version available'
    else
      pv = Version.create(number: version.number, production: true, user: current_user)

      if pv.persisted?
        flash.notice = 'Production data updated'
      else

        flash.alert = "Production data not updated: #{version.inspect} #{pv.errors.inspect}"
      end

      redirect_to dashboards_path
    end
  end

  private

  def csv_model(csv_type)
    return Institution if csv_type == 'Institution'
    InstitutionBuilder::TABLES.select { |model| model.name == csv_type }.first
  end
end

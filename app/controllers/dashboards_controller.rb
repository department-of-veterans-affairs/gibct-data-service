# frozen_string_literal: true
class DashboardsController < ApplicationController
  include Flashable

  def index
    @uploads = Upload.last_uploads
  end

  def build
    results = InstitutionBuilder.run(current_user)

    @version = results[:version]
    @error_msg = results[:error_msg]

    if @error_msg.present?
      flash.alert = "Preview Data not built: #{@error_msg}"
    else
      flash.notice = "Preview Data (#{@version.number}) built successfully"
    end
  end

  def export
    klass = csv_model(params[:csv_type])
    csv_data = klass.export

    respond_to do |format|
      format.csv { send_data csv_data, type: 'text/csv' }
    end
  rescue CsvTypeError => e
    redirect_to dashboards_path, alert: e.message
  end

  def push
    version = Version.preview_version

    if version.blank?
      flash.alert = 'No preview version available'
    else
      pv = Version.create(number: version.number, production: true, user: current_user)

      if pv.persisted?
        flash.notice = 'Production data updated'
      else
        flash.alert = 'Production data not updated, remains at previous production version'
      end
    end

    redirect_to dashboards_path
  end

  private

  def csv_model(csv_type)
    return Institution if csv_type == 'Institution'

    model = InstitutionBuilder::TABLES.select { |klass| klass.name == csv_type }.first
    raise CsvTypeError, csv_type if model.blank?

    model
  end
end

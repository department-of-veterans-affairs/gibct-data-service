# frozen_string_literal: true
class DashboardsController < ApplicationController
  def index
    @uploads = Upload.last_uploads
    # TODO: fix the scopes on Version, particularly .newest so that it returns a AR:Relation
    # TODO: eventually export and push should support passing in a version uuid
    @production = Version.includes(:user).where(production: true).order(created_at: :desc).limit(1)
    @preview_versions = Version.includes(:user).where(production: false).order(created_at: :desc).limit(1)
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

    redirect_to dashboards_path
  end

  def export
    klass = csv_model(params[:csv_type])

    respond_to do |format|
      format.csv { send_data klass.export, type: 'text/csv', filename: "#{klass.name}.csv" }
    end
  rescue ArgumentError, ActionController::UnknownFormat => e
    Rails.logger.error e.message
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
    return model if model.present?

    raise(ArgumentError, "#{csv_type} is not a valid CSV type") if model.blank?
  end
end

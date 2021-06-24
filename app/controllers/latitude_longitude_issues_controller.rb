# frozen_string_literal: true

class LatitudeLongitudeIssuesController < ApplicationController
  def export
    send_data CensusLatLong.export, type: 'application/zip', filename: "#{CensusLatLong.name}.zip"
  end

  def import
    flash.alert = 'Not implemented'

    redirect_to dashboards_path
  end
end

# frozen_string_literal: true

class VersionPublicExportsController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    version_id = params[:id] == 'latest' ? Version.current_production&.id : params[:id]
    export = VersionPublicExport.find_by(version_id: version_id)

    if export
      send_data(export.data, filename: "public_export_#{export.version.number}.gz", type: export.file_type, disposition: 'attachment')
    else
      raise ActionController::RoutingError, 'Not Found'
    end
  end
end

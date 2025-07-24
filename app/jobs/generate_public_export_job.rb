# frozen_string_literal: true

class GeneratePublicExportJob < ApplicationJob
  def perform(version_id)
    version = Version.find(version_id)
    existing_export = VersionPublicExport.find_by(version: version)

    return if existing_export

    VersionPublicExport.build(version.id)
  end
end

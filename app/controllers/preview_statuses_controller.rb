# frozen_string_literal: true

class PreviewStatusesController < ApplicationController
  include CommonInstitutionBuilder::VersionGeneration

  def poll
    @preview_status = PreviewGenerationStatusInformation.latest
    @preview_generation_completed = @preview_status.nil? || check_completion
    @production_versions = Version.production.newest.includes(:user).limit(1) if @preview_generation_completed

    respond_to do |format|
      format.turbo_stream { render template: 'messages/update' }
    end
  end

  private

  def check_completion
    return false unless @preview_status.current_progress.start_with?(PUBLISH_COMPLETE_TEXT) ||
                        @preview_status.current_progress.start_with?('There was an error')

    PreviewGenerationStatusInformation.delete_all
    # maintain the indexes and tables in the local, dev & staging envs.
    # The production env times out and periodic maintenance should be run
    # in production anyway.
    InstitutionTablesMaintenanceJob.perform_later unless production?

    true
  end
end

# frozen_string_literal: true

class PreviewStatusesController < ApplicationController
  include CommonInstitutionBuilder::VersionGeneration

  before_action :check_status, only: :poll

  def poll
    return head :no_content if @preview_status.blank?

    respond_to do |format|
      format.turbo_stream { render template: 'messages/update' }
    end
  end

  private

  def check_status
    @preview_status = PreviewGenerationStatusInformation.last
    @preview_generation_completed = check_completion
  end

  def check_completion
    return if @preview_status.blank?

    completed = false

    if @preview_status.current_progress.start_with?(PUBLISH_COMPLETE_TEXT) ||
       @preview_status.current_progress.start_with?('There was an error')
      completed = true
      PreviewGenerationStatusInformation.delete_all
      # maintain the indexes and tables in the local, dev & staging envs.
      # The production env times out and periodic maintenance should be run
      # in production anyway.
      InstitutionTablesMaintenanceJob.perform_later unless production?
    end

    completed
  end
end

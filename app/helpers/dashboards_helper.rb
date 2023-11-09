# frozen_string_literal: true

module DashboardsHelper
  include CommonInstitutionBuilder::VersionGeneration

  def latest_upload_class(upload)
    return '' if upload.ok?
    return 'danger' if UPLOAD_TYPES_REQUIRED_NAMES.include?(upload.csv_type)

    'warning'
  end

  def latest_upload_title(upload)
    return '' if upload.ok?
    return 'Missing required upload' if UPLOAD_TYPES_REQUIRED_NAMES.include?(upload.csv_type)

    'Missing upload'
  end

  def can_generate_preview(preview_versions)
    return 'disabled' if preview_versions[0]&.generating?

    # We also want to disable while publishing is in progress
    pgsi = PreviewGenerationStatusInformation.last
    return 'disabled' unless
      pgsi.nil? ||
      pgsi.current_progress.start_with?(PUBLISH_COMPLETE_TEXT) ||
      pgsi.current_progress.start_with?('There was an error')
  end

  def cannot_fetch_api(csv_type)
    Upload.fetching_for?(csv_type)
  end

  def preview_generation_started?
    PreviewGenerationStatusInformation.exists?
  end

  def preview_generation_completed?
    return unless preview_generation_started?

    completed = false

    pgsi = PreviewGenerationStatusInformation.last
    if pgsi.current_progress.start_with?(PUBLISH_COMPLETE_TEXT) ||
       pgsi.current_progress.start_with?('There was an error')
      completed = true
      PreviewGenerationStatusInformation.delete_all
      # maintain the indexes and tables in the local, dev & staging envs.
      # The production env times out and periodic maintenance should be run
      # in production anyway.
      PerformInsitutionTablesMaintenanceJob.perform_later unless production?
    end

    completed
  end

  def locked_fetches_exist?
    Upload.locked_fetches_exist?
  end

  def formatted_keywords(value)
    value.gsub('[','').gsub(']','').gsub('/i','').gsub('/','')
  end
end

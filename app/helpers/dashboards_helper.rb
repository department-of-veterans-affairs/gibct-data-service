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
    'disabled' unless
      pgsi.nil? ||
      pgsi.current_progress.start_with?(PUBLISH_COMPLETE_TEXT) ||
      pgsi.current_progress.start_with?('There was an error')
  end

  def generating_in_progress?(preview_versions)
    return true if preview_versions[0]&.generating?

    pgsi = PreviewGenerationStatusInformation.last
    pgsi.nil? ? false : true
  end

  def appears_to_be_stuck?(preview_versions)
    preview_version = preview_versions[0]
    if preview_version.nil?
      pgsi = PreviewGenerationStatusInformation.last
      return pgsi.nil? ? false : true
    end

    return true if preview_version.created_at < 30.minutes.ago && preview_version.completed_at.nil?

    false
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

  def formatted_keywords(accreditation_type)
    AccreditationTypeKeyword
      .where(accreditation_type: accreditation_type)
      .order(:keyword_match)
      .pluck(:keyword_match)
      .join(', ')
  end

  def disable_upload?(upload)
    CSV_TYPES_NO_UPLOAD_TABLE_NAMES.include?(upload.csv_type)
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def current_user_can_upload?
    return true if ENV.fetch('RAILS_ENV').eql?('test') || ENV.fetch('RAILS_ENV').eql?('development')

    if staging?
      return true if current_user.email.downcase.start_with?('nfstern')
      return true if current_user.email.downcase.start_with?('noah')
      return true if current_user.email.downcase.start_with?('gpuhala')
      return true if current_user.email.downcase.start_with?('gregg')
    end

    false
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end

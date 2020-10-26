# frozen_string_literal: true

module DashboardsHelper
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
    'disabled' if preview_versions[0]&.generating?
  end

  def cannot_fetch_api(csv_type)
    Upload.fetching_for?(csv_type)
  end
end

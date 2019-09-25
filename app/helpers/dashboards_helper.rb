# frozen_string_literal: true

module DashboardsHelper
  def latest_upload_class(upload)
    return '' if upload.ok?
    return 'danger' if CSV_TYPES_REQUIRED_TABLE_NAMES.include?(upload.csv_type)
    'warning'
  end

  def latest_upload_title(upload)
    return '' if upload.ok?
    return 'Missing required upload' if CSV_TYPES_REQUIRED_TABLE_NAMES.include?(upload.csv_type)
    'Missing upload'
  end

  def can_generate_preview(preview_versions)
    'disabled' if preview_versions[0]&.generating?
  end
end

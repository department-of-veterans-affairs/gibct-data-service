# frozen_string_literal: true

module DashboardsHelper
  def latest_upload_class(upload)
    return '' if upload.ok?
    return 'danger' if CSV_TYPES_REQUIRED_TABLE_NAMES.include?(upload.csv_type)
    return 'warning' if !CSV_TYPES_REQUIRED_TABLE_NAMES.include?(upload.csv_type)
  end

  def latest_upload_title(upload)
    return '' if upload.ok?
    return 'Missing required upload' if CSV_TYPES_REQUIRED_TABLE_NAMES.include?(upload.csv_type)
    return 'Missing upload' if !CSV_TYPES_REQUIRED_TABLE_NAMES.include?(upload.csv_type)
  end
end

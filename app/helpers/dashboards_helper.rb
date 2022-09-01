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

  # In production Hide upload types that are disabled via boolean property not_prod_ready?
  #
  # If an upload type has a feature_flag String property check if enabled
  def hide_upload_type(csv_type)
    return true if production? && UPLOAD_TYPES_NO_PROD_NAMES.include?(csv_type)

    upload_type = UPLOAD_TYPES.select do |upload|
      name = if upload[:klass].is_a? String
               upload[:klass]
             else
               upload[:klass].name
             end

      name == csv_type
    end.first

    upload_type.present?
  end
end

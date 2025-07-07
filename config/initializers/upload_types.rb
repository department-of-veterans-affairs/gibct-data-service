Rails.application.config.to_prepare do
  UPLOAD_TYPES ||= [
      *GROUP_FILE_TYPES,
      *CSV_TYPES_TABLES,
      *ONLINE_TYPES,
  ].freeze

  # Excludes ONLINE_TYPES, which cannot be updated via CSV upload
  TRUE_UPLOAD_TYPES ||= [
    *GROUP_FILE_TYPES,
    *CSV_TYPES_TABLES
  ].freeze

  stringify_klass_name = ->(upload) do
    klass = upload[:klass]
    if klass.is_a? String
      klass
    else
      klass.name
    end
  end

  UPLOAD_TYPES_ALL_NAMES ||= UPLOAD_TYPES.map(&stringify_klass_name).freeze

  TRUE_UPLOAD_TYPES_ALL_NAMES ||= TRUE_UPLOAD_TYPES.map(&stringify_klass_name).freeze

  UPLOAD_TYPES_REQUIRED_NAMES ||= UPLOAD_TYPES.select { |upload| upload[:required?] }.map(&stringify_klass_name).freeze
  
  UPLOAD_TYPES_NO_PROD_NAMES ||= UPLOAD_TYPES.select { |upload| upload[:not_prod_ready?] }.map(&stringify_klass_name).freeze
end
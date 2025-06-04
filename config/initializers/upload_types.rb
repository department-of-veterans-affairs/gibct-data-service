Rails.application.config.to_prepare do
  UPLOAD_TYPES ||= [
      *GROUP_FILE_TYPES,
      *CSV_TYPES_TABLES,
  ].freeze

  parse_name = lambda do |upload|
    klass = upload[:klass]
    if klass.is_a? String
      klass
    else
      klass.name
    end
  end

  UPLOAD_TYPES_ALL_NAMES ||= UPLOAD_TYPES.map(&parse_name).freeze

  # Inactive upload types won't appear on dashboard, but can still be uploaded via uploads/new/[:csv_type]
  UPLOAD_TYPES_ACTIVE_NAMES ||= UPLOAD_TYPES.reject { |upload| upload[:inactive?] }
                                            .map(&parse_name).freeze

  UPLOAD_TYPES_REQUIRED_NAMES ||= UPLOAD_TYPES.select { |upload| upload[:required?] }
                                              .map(&parse_name).freeze

  UPLOAD_TYPES_NO_PROD_NAMES ||= UPLOAD_TYPES.select { |upload| upload[:not_prod_ready?] }
                                             .map(&parse_name).freeze
end

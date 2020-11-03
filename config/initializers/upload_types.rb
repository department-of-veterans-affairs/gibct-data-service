UPLOAD_TYPES = [
    *GROUP_FILE_TYPES,
    *CSV_TYPES_TABLES,
].freeze

UPLOAD_TYPES_ALL_NAMES = UPLOAD_TYPES.map do |upload|
  klass = upload[:klass]
  if klass.is_a? String
    klass
  else
    klass.name
  end
end.freeze

UPLOAD_TYPES_REQUIRED_NAMES = UPLOAD_TYPES.select { |upload| upload[:required?] }.map do |upload|
  klass = upload[:klass]
  if klass.is_a? String
    klass
  else
    klass.name
  end
end.freeze

UPLOAD_TYPES_NO_PROD_NAMES = UPLOAD_TYPES.select { |upload| upload[:not_prod_ready?] }.map do |upload|
  klass = upload[:klass]
  if klass.is_a? String
    klass
  else
    klass.name
  end
end.freeze
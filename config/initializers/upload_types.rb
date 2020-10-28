UPLOAD_TYPES = [
    *CSV_TYPES_TABLES,
    *GROUP_FILE_TYPES
].freeze

UPLOAD_TYPES_ALL_NAMES = UPLOAD_TYPES.map do |upload|
  klass = upload[:klass]
  return klass if klass.is_a? String
  klass.name
end.freeze

UPLOAD_TYPES_REQUIRED_NAMES = UPLOAD_TYPES.select { |upload| upload[:required?] }.map do |upload|
  klass = upload[:klass]
  return klass if klass.is_a? String
  klass.name
end.freeze

UPLOAD_TYPES_NO_PROD_NAMES = UPLOAD_TYPES.select { |upload| upload[:not_prod_ready?] }.map do |upload|
  klass = upload[:klass]
  return klass if klass.is_a? String
  klass.name
end.freeze
UPLOAD_TYPES = [
    *CSV_TYPES_TABLES
].freeze

def klass_name(upload)
  klass = upload[:klass]
  return klass if klass.is_a? String
  klass.name
end

def klass_names(upload_types)
  upload_types.map do |upload|
    klass_name(upload)
  end.freeze
end

UPLOAD_TYPES_REQUIRED_NAMES = klass_names(UPLOAD_TYPES.select { |upload| upload[:required?] })
UPLOAD_TYPES_ALL_NAMES = UPLOAD_TYPES.map { |upload| klass_name(upload) }.freeze
UPLOAD_TYPES_NO_PROD_NAMES = klass_names(UPLOAD_TYPES.select { |upload| upload[:not_prod_ready?] })
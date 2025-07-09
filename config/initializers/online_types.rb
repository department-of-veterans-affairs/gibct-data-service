Rails.application.config.to_prepare do
  ONLINE_TYPES ||= [
    { klass: CalculatorConstant, required?: false },
  ].freeze

  ONLINE_TYPES_NAMES ||= ONLINE_TYPES.map { |g| g[:klass] }.freeze
  ONLINE_TYPES_ALL_TABLES_CLASSES ||= ONLINE_TYPES.map { |table| table[:klass] }.freeze
end

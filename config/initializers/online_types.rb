Rails.application.config.to_prepare do
  ONLINE_TYPES ||= [
    { klass: CalculatorConstant, required?: false },
  ].freeze

  ONLINE_TYPES_NAMES ||= ONLINE_TYPES.map { |g| g[:klass] }.freeze
end

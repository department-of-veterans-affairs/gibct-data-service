# frozen_string_literal: true

class CalculatorConstant < ImportableRecord
  belongs_to :cost_of_living_adjustment, optional: true

  CSV_CONVERTER_INFO = {
    'name' => { column: :name, converter: Converters::UpcaseConverter },
    'value' => { column: :float_value, converter: Converters::NumberConverter },
    'description' => { column: :description, converter: Converters::BaseConverter }
  }.freeze

  default_scope { order('name') }

  after_create :set_cola_if_exists

  validates :name, uniqueness: true, presence: true
  validates :float_value, presence: true
  validate :description_cannot_reference_more_than_one_benefit_type

  delegate :benefit_type, to: :cost_of_living_adjustment, allow_nil: true

  scope :version, lambda { |version|
    # TODO: where(version: version)
  }
  scope :subject_to_cola, -> { where.not(cost_of_living_adjustment_id: nil) }

  alias_attribute :value, :float_value
  alias cola cost_of_living_adjustment

  # Associate with COLA if benefit type parseable from description
  def set_cola_if_exists
    return if cola.present? || matched_benefit_types.empty?

    benefit_type = matched_benefit_types.first
    cola = CostOfLivingAdjustment.find_by(benefit_type:)
    update(cost_of_living_adjustment: cola)
  end

  def apply_cola
    return false if cola.nil?

    percent_increase = 1 + (cola.rate / 100)
    update(float_value: float_value * percent_increase)
  end

  private

  # Parse benefit types from description
  def matched_benefit_types
    benefit_type_options = CostOfLivingAdjustment::BENEFIT_TYPES.join('|') # e.g. "30|33|35|1606"
    description.scan(/(?:Chapter|Ch\.?) (#{benefit_type_options})/).flatten
  end

  # Validate against multiple matches to ensure benefit type can be parsed from description
  def description_cannot_reference_more_than_one_benefit_type
    if matched_benefit_types.length > 1
      errors.add(:description, "cannot reference more than one benefit type: Ch. #{matched_benefit_types.join(', Ch. ')}")
    end
  end
end

# frozen_string_literal: true

class CalculatorConstant < ImportableRecord
  CSV_CONVERTER_INFO = {
    'name' => { column: :name, converter: Converters::UpcaseConverter },
    'value' => { column: :float_value, converter: Converters::NumberConverter },
    'description' => { column: :description, converter: Converters::BaseConverter }
  }.freeze

  belongs_to :rate_adjustment, optional: true

  validates :name, uniqueness: true, presence: true
  validates :float_value, presence: true

  attr_readonly :name

  delegate :benefit_type, to: :rate_adjustment, allow_nil: true

  default_scope { order('name') }

  # removing this breaks the caclulator constant request spec (v0)
  # TODO: remove without breaking functionality
  scope :version, lambda { |version|
    # TODO: where(version: version)
  }

  def self.unpublished?
    Upload.since_last_version.any? { |upload| upload.csv_type == name }
  end

  # Associate with rate adjustment if benefit type parseable from description
  # Explicitly used for seeds/migrations
  def set_rate_adjustment_if_exists
    return false if rate_adjustment.present? || matched_benefit_types.empty?

    benefit_type = matched_benefit_types.first
    rate_adjustment = RateAdjustment.find_by(benefit_type:)
    update(rate_adjustment:)
  end

  def apply_rate_adjustment
    return if rate_adjustment.nil?

    percent_increase = 1 + (rate_adjustment.rate / 100)
    self.float_value = (float_value * percent_increase).round(2)
    tap(&:save) # return updated object instead of true
  end

  private

  # Parse benefit types from description
  def matched_benefit_types
    return [] unless description

    benefit_type_options = RateAdjustment.pluck(:benefit_type).join('|') # e.g. "30|31|33|35|1606"
    description.scan(/(?:Chapter|Ch\.?) (#{benefit_type_options})/).flatten
  end
end

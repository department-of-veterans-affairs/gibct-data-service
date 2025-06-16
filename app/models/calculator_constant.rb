# frozen_string_literal: true

class CalculatorConstant < ImportableRecord
  # No longer importable record, updated instead via calculator constants dashboard
  # Leaving csv settings in place in case spreadsheet upload desired again in future
  CSV_CONVERTER_INFO = {
    'name' => { column: :name, converter: Converters::UpcaseConverter },
    'value' => { column: :float_value, converter: Converters::NumberConverter },
    'description' => { column: :description, converter: Converters::BaseConverter }
  }.freeze

  CONSTANT_NAMES = %w[
    AVEGRADRATE
    AVEREPAYMENTRATE
    AVERETENTIONRATE
    AVESALARY
    AVGBAH
    AVGDODBAH
    AVGVABAH
    BSCAP
    BSOJTMONTH
    CORRESPONDTFCAP
    DEARATEFULLTIME
    DEARATEOJT
    DEARATEONEHALF
    DEARATETHREEQUARTERS
    DEARATEUPTOONEHALF
    DEARATEUPTOONEQUARTER
    FISCALYEAR
    FLTTFCAP
    MGIB2YRRATE
    MGIB3YRRATE
    SRRATE
    TFCAP
    VRE0DEPRATE
    VRE0DEPRATEOJT
    VRE1DEPRATE
    VRE1DEPRATEOJT
    VRE2DEPRATE
    VRE2DEPRATEOJT
    VREINCRATE
    VREINCRATEOJT
  ].freeze

  belongs_to :rate_adjustment, optional: true

  default_scope { order('name') }

  validates :name, uniqueness: true, presence: true, inclusion: { in: CONSTANT_NAMES }
  validates :float_value, presence: true

  attr_readonly :name

  alias_attribute :value, :float_value

  delegate :benefit_type, to: :rate_adjustment, allow_nil: true

  scope :by_rate_adjustment, ->(rate_adjustment_id) { where(rate_adjustment_id:) }
  scope :version, lambda { |version|
    # TODO: where(version: version)
  }

  # Associate with rate adjustment if benefit type parseable from description
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
    benefit_type_options = RateAdjustment.pluck(:benefit_type).join('|') # e.g. "30|31|33|35|1606"
    description.scan(/(?:Chapter|Ch\.?) (#{benefit_type_options})/).flatten
  end
end

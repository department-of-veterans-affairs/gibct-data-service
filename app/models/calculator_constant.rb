# frozen_string_literal: true
class CalculatorConstant < ActiveRecord::Base
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'name' => { column: :name, converter: UpcaseConverter },
    'value' => { column: :float_value, converter: NumberConverter }
  }.freeze

  default_scope { order('name') }

  validates :name, uniqueness: true, presence: true
  validate :value_not_nil

  # Supports either numeric or string values
  def value
    string_value || float_value
  end

  scope :version, lambda { |version|
    # TODO: where(version: version)
  }

  private

  def value_not_nil
    errors.add(:base, 'you must specify a value') if value.blank?
  end
end

# frozen_string_literal: true
class CalculatorConstant < ActiveRecord::Base
  default_scope { order('name') }

  validates :name, uniqueness: true, presence: true

  # Supports either numeric or string values
  def value
    string_value || float_value
  end

  scope :version, ->(version) {}
end

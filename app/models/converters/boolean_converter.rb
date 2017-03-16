# frozen_string_literal: true

class BooleanConverter < BaseConverter
  TRUTHS = %w(true t yes ye y 1 on).freeze

  def self.convert(value)
    value = super(value)
    value.blank? ? nil : TRUTHS.include?(value.to_s)
  end
end

# frozen_string_literal: true

class BooleanConverter < BaseConverter
  def self.convert(value)
    value = super(value)

    return nil if value.blank?
    value.to_s.match(/\A(true|t|yes|ye|y|1|on)\z/i).present? ? true : false
  end
end

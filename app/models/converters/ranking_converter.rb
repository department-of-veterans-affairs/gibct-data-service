# frozen_string_literal: true

class RankingConverter < BaseConverter
  def self.convert(value)
    value = value.to_i

    return value if value.nil?

    value = 5 if value > 5
    value = nil if value <= 0
    value
  end
end

# frozen_string_literal: true

# Right stips and upcases institution names.
class InstitutionConverter < BaseConverter
  def self.convert(value)
    value = super(value.to_s)
    value.blank? ? nil : value.upcase
  end
end

# frozen_string_literal: true
module OptionalSerializedAttributes
  extend ActiveSupport::Concern

  class_methods do
    def attribute_if_positive(optional_attribute)
      attribute optional_attribute, if: -> { object.send(optional_attribute).positive? }
    end
  end
end

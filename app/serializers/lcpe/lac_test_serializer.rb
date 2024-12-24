# frozen_string_literal: true

module Lcpe
  class LacTestSerializer < ActiveModel::Serializer
    attributes :name, :value
  end
end

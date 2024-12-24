# frozen_string_literal: true

module Lcpe
  class ExamTestSerializer < ActiveModel::Serializer
    attributes :name, :value
  end
end

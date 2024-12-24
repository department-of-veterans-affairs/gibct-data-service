# frozen_string_literal: true

module Lcpe
  class ExamSerializer < ActiveModel::Serializer
    attribute :facility_code
    attribute :nexam_nm
  end
end

# frozen_string_literal: true

module Lcpe
  class ExamTestSerializer < ActiveModel::Serializer
    attr_reader :resource, :instance_options

    def initialize(resource, instance_options={})
      @resource = resource
      @instance_options = instance_options
    end
    
    def json_key
      'exam_test'
    end

    def serializable_hash(*)
      {
        name: resource.descp_txt,
        fee: resource.fee_amt,
        begin_date: resource.begin_dt,
        end_date: resource.end_dt
      }
    end
  end
end

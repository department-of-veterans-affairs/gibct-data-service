# frozen_string_literal: true

module Lcpe
  class LacTestSerializer < ActiveModel::Serializer
    attr_reader :resource, :instance_options

    def initialize(resource, instance_options={})
      @resource = resource
      @instance_options = instance_options
    end
    
    def json_key
      'lac_test'
    end

    def serializable_hash(*)
      {
        name: resource.test_nm,
        fee: resource.fee_amt
      }
    end
  end
end

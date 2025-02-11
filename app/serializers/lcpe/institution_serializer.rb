# frozen_string_literal: true

module Lcpe
  class InstitutionSerializer < ActiveModel::Serializer
    attr_reader :resource, :instance_options

    def initialize(resource, instance_options = {})
      @resource = resource
      @instance_options = instance_options
    end

    def json_key
      'institution'
    end

    def serializable_hash(*)
      {
        name: resource.institution,
        physical_address: physical_address,
        mailing_address: mailing_address,
        web_address: resource.website_link
      }
    end

    def physical_address
      {
        address_1: resource.physical_address_1,
        address_2: resource.physical_address_2,
        address_3: resource.physical_address_3,
        city: resource.physical_city,
        state: resource.physical_state,
        zip: resource.physical_zip,
        country: resource.physical_country
      }
    end

    def mailing_address
      {
        address_1: resource.address_1,
        address_2: resource.address_2,
        address_3: resource.address_3,
        city: resource.city,
        state: resource.state,
        zip: resource.zip,
        country: resource.country
      }
    end
  end
end

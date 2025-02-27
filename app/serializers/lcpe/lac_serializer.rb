# frozen_string_literal: true

module Lcpe
  class LacSerializer < ActiveModel::Serializer
    attr_reader :resource, :instance_options

    def initialize(resource, instance_options = {})
      @resource = resource
      @instance_options = instance_options
    end

    def json_key
      'lac'
    end

    def serializable_hash(*)
      {
        enriched_id: resource['enriched_id'],
        lac_nm: resource['lac_nm'],
        edu_lac_type_nm: resource['edu_lac_type_nm'],
        state: resource['state']
      }.tap(&method(:add_tests)).tap(&method(:add_institution))
    end

    def add_tests(data)
      return unless instance_options[:action] == 'show' && resource&.tests.present?

      data[:tests] = resource.tests.map { |test| LacTestSerializer.new(test).serializable_hash }
    end

    def add_institution(data)
      return unless instance_options[:action] == 'show' && resource&.institution.present?

      data[:institution] = InstitutionSerializer.new(resource.institution).serializable_hash
    end
  end
end

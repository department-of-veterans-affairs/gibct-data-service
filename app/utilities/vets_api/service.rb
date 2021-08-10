# frozen_string_literal: true

require 'vets_api/client'

module VetsApi
  class Service
    def self.feature_enabled?(feature)
      client.feature_toggles({features: feature}).body[:data][:features].filter{ |flag| flag[:name] == feature }.first[:value]
    end

    def self.client
      VetsApi::Client.new
    end
  end
end
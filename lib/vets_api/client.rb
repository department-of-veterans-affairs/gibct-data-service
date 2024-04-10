# frozen_string_literal: true

module VetsApi
  class ParamsMissingError < StandardError; end

  # Core class responsible for api interface operations
  class Client < Common::Client::Base
    configuration VetsApi::Configuration

    def feature_toggles(params)
      raise(ParamsMissingError, 'No feature flags provided for the features param') if params.blank? || params[:features].blank?

      perform(:get, 'feature_toggles', params)
    end
  end
end

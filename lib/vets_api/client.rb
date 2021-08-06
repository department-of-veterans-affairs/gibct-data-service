# frozen_string_literal: true

module VetsApi
  class ParamsMissingError < StandardError; end

  # Core class responsible for api interface operations
  class Client < Common::Client::Base
    configuration VetsApi::Configuration

    def feature_toggles(params)
      if params.blank? || params[:features].blank?
        raise(ParamsMissingError, 'No feature flags provided for the features param')
      end

      perform(:get, 'feature_toggles', params)
    end
  end
end

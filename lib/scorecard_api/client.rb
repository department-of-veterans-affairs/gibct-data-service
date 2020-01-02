require 'common/client/base'
require 'scorecard_api/configuration'

module ScorecardApi
  # Core class responsible for api interface operations
  class Client < Common::Client::Base
    configuration ScorecardApi::Configuration


    def get_schools(params = {})
      perform(:get, 'schools', merged_params(params))
    end

    private

    def merged_params(params = {})
      params.merge(api_key: Settings.scorecard.api_key)
    end
  end
end
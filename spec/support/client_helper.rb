require 'rails_helper'
require 'common/client/base'

module Specs
  module Common
    module Client
      class TestConfiguration < DefaultConfiguration
        def adapter_only
          true
        end
      end

      class TestService < ::Common::Client::Base
        configuration TestConfiguration
      end

      class ErrorConfiguration < DefaultConfiguration
        def adapter_only
          true
        end
      end

      class ErrorService < ::Common::Client::Base
        configuration TestConfiguration
      end
    end
  end
end
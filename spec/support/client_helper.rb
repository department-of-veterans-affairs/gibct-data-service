# frozen_string_literal: true

require 'rails_helper'
require 'common/client/base'
require 'common/exceptions/external/backend_service_exception'
require 'support/configuration_helper'

module Specs
  module Common
    module Client
      class TestService < ::Common::Client::Base
        configuration TestConfiguration
      end

      class BackendServiceExceptionService < ::Common::Client::Base
        configuration BackendServiceExceptionConfiguration
      end

      class TimeoutExceptionService < ::Common::Client::Base
        configuration TimeoutConfiguration
      end

      class ParsingErrorExceptionService < ::Common::Client::Base
        configuration ParsingErrorConfiguration
      end

      class ClientErrorExceptionService < ::Common::Client::Base
        configuration ClientErrorConfiguration
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'common/client/base'
require 'common/exceptions/external/backend_service_exception'

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

      class BackendServiceExceptionConfiguration < DefaultConfiguration
        def connection
          raise ::Common::Exceptions::BackendServiceException, 'TEST404'
        end
      end

      class BackendServiceExceptionService < ::Common::Client::Base
        configuration BackendServiceExceptionConfiguration
      end

      class TimeoutConfiguration < DefaultConfiguration
        def connection
          raise Timeout::Error, 'TEST404'
        end
      end

      class TimeoutExceptionService < ::Common::Client::Base
        configuration TimeoutConfiguration
      end

      class ParsingErrorConfiguration < DefaultConfiguration
        def connection
          raise Faraday::ParsingError, 'TEST404'
        end
      end

      class ParsingErrorExceptionService < ::Common::Client::Base
        configuration ParsingErrorConfiguration
      end

      class ClientErrorConfiguration < DefaultConfiguration
        def connection
          raise Faraday::ClientError, 'TEST404'
        end
      end

      class ClientErrorExceptionService < ::Common::Client::Base
        configuration ClientErrorConfiguration
      end
    end
  end
end

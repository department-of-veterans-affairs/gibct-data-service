# frozen_string_literal: true

require 'rails_helper'
require 'common/client/base'
require 'common/exceptions/external/backend_service_exception'
require 'common/client/configuration/base'

module Specs
  module Common
    module Client
      class TestConfiguration < DefaultConfiguration
        def adapter_only
          true
        end
      end

      class BackendServiceExceptionConfiguration < DefaultConfiguration
        def connection
          raise ::Common::Exceptions::BackendServiceException, 'TEST404'
        end
      end

      class TimeoutConfiguration < DefaultConfiguration
        def connection
          raise Timeout::Error, 'TEST404'
        end
      end

      class ParsingErrorConfiguration < DefaultConfiguration
        def connection
          raise Faraday::ParsingError, 'TEST404'
        end
      end

      class ClientErrorConfiguration < DefaultConfiguration
        def connection
          raise Faraday::ClientError, 'TEST404'
        end
      end

      class ServiceException < StandardError
      end

      module Configuration
        class NoServiceExceptionConfiguration < ::Common::Client::Configuration::Base
        end
      end
    end
  end
end

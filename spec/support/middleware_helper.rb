# frozen_string_literal: true

require 'rails_helper'
require 'common/client/base'
require 'common/exceptions/external/backend_service_exception'
require 'common/client/configuration/base'

module Specs
  module Common
    module Client
      class MockEnv < Faraday::Env
        attr_accessor :body, :status
        def initialize(body: nil, status: nil)
          self.body = body
          self.status = status
        end
      end
    end
  end
end

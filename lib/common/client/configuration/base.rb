# frozen_string_literal: true

module Common
  module Client
    module Configuration
      ##
      # Base class for HTTP service configurations. This class should not be used directly.
      # Use {Common::Client::Configuration::REST} or {Common::Client::Configuration::SOAP} instead.
      #
      class Base
        include Singleton

        # @!group Class Attributes
        # @!attribute [rw]
        # timeout for opening the connection
        class_attribute :open_timeout

        # @!group Class Attributes
        # @!attribute [rw]
        # timeout for reading a response
        class_attribute :read_timeout

        # @!group Class Attributes
        # @!attribute [rw]
        # allowed requests types e.g. `%i[get put post delete].freeze`
        class_attribute :request_types

        # @!group Class Attributes
        # @!attribute [rw]
        # value for the User-Agent header
        class_attribute :user_agent

        # @!group Class Attributes
        # @!attribute [rw]
        # headers to include in all requests
        class_attribute :base_request_headers

        self.open_timeout = 15
        self.read_timeout = 15
        self.request_types = %i[get put post delete].freeze
        self.user_agent = 'VA.gov Agent'
        self.base_request_headers = {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'User-Agent' => user_agent
        }.freeze

        ##
        # The base path to use for all requests. Implemented by sub classes.
        #
        def base_path
          raise NotImplementedError, "Subclass #{self.class.name} of Configuration must implement base_path"
        end

        ##
        # The service name that shows up in breakers metrics and logs. Implemented by sub classes.
        #
        def service_name
          raise NotImplementedError, "Subclass #{self.class.name} of Configuration must implement service_name"
        end

        ##
        # Creates a custom service exception with the same namespace as the implementing class.
        #
        # @return Common::Exceptions::External::BackendServiceException exception with the class' namespace
        #
        def service_exception
          if current_module.const_defined?('ServiceException')
            current_module.const_get('ServiceException')
          else
            current_module.const_set('ServiceException', Class.new(Common::Exceptions::External::BackendServiceException))
          end
        end

        ##
        # Default request options, sets the read and open timeouts.
        #
        # @return Hash default request options.
        #
        def request_options
          {
            open_timeout: open_timeout,
            timeout: read_timeout
          }
        end

        private

        # deconstantize fetches "AA::BB::" from AA::BB::ClassName, and constantize returns that as a constant.
        def current_module
          self.class.name.deconstantize.constantize
        end
      end
    end
  end
end

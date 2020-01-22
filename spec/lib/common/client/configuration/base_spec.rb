# frozen_string_literal: true

require 'rails_helper'
require 'common/client/configuration/base'
require 'support/configuration_helper'

describe Common::Client::Configuration::Base do
  subject(:base_configuration) { described_class.instance }

  let(:configuration) { Specs::Common::Client::TestConfiguration.instance }

  describe '#service_exception' do
    it 'creates an exception class dynamically based on module name' do
      service_exception_config = Specs::Common::Client::Configuration::NoServiceExceptionConfiguration.instance
      expect(Specs::Common::Client::Configuration).not_to be_const_defined('ServiceException')
      expect(service_exception_config.service_exception).to eq(Specs::Common::Client::Configuration::ServiceException)
      expect(Specs::Common::Client::Configuration).to be_const_defined('ServiceException')
    end

    it 'returns Specs::Common::Client::ServiceException' do
      expect(Specs::Common::Client).to be_const_defined('ServiceException')
      expect(configuration.service_exception).to eq(Specs::Common::Client::ServiceException)
    end
  end

  describe '#base_path' do
    it 'raises NotImplementedError' do
      expect { base_configuration.base_path }.to raise_error(NotImplementedError)
    end
  end

  describe '#request_options' do
    let(:request_options) { base_configuration.request_options }

    it 'returns default open_timeout' do
      expect(request_options[:open_timeout]).to eq(15)
    end

    it 'returns default read_timeout' do
      expect(request_options[:timeout]).to eq(15)
    end
  end

  describe '#current_module' do
    it 'returns self.class.name.deconstantize.constantize' do
      expect(base_configuration.send(:current_module)).to eq(base_configuration.class.name.deconstantize.constantize)
    end
  end
end

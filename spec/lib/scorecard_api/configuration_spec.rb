# frozen_string_literal: true

require 'rails_helper'
require 'scorecard_api/configuration'

describe ScorecardApi::Configuration do
  describe '.open_timeout' do
    context 'when Settings.scorecard.open_timeout is not set' do
      it 'uses the setting' do
        expect(ScorecardApi::Configuration.instance.open_timeout)
            .to eq(Common::Client::Configuration::Base.instance.open_timeout)
      end
    end
  end

  describe '.read_timeout' do
    context 'when Settings.scorecard.timeout is not set' do
      it 'uses the setting' do
        expect(ScorecardApi::Configuration.instance.read_timeout)
            .to eq(Common::Client::Configuration::Base.instance.read_timeout)
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe VetsApi::Client do
  let(:client) { described_class.new }

  it 'gets feature toggles' do
    allow(client).to receive(:perform)
    client.feature_toggles({ features: 'feature_flag' })
    expect(client).to have_received(:perform)
  end

  it 'returns ParamMissingError' do
    expect { client.feature_toggles({}) }.to raise_error(VetsApi::ParamsMissingError)
  end
end

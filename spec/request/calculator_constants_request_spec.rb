# frozen_string_literal: true
require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'

RSpec.describe 'calculator_constants', type: :request do
  before(:each) do
    create(:version, :preview)
    create(:version, :production)
  end

  it 'uses LINK_HOST in self link' do
    get v0_calculator_constants_path
    links = JSON.parse(response.body)['links']
    expect(links['self']).to start_with(ENV['LINK_HOST'])
  end
end

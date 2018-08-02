# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'

RSpec.describe 'institutions', type: :request do
  before(:each) do
    create(:version, :preview)
    create(:version, :production)
  end

  context '#autocomplete' do
    it 'uses LINK_HOST in self link' do
      create(:institution, :in_chicago)
      get '/v0/institutions/autocomplete?term=uni'
      links = JSON.parse(response.body)['links']
      expect(links['self']).to start_with(ENV['LINK_HOST'])
    end
  end

  context '#search' do
    it 'uses LINK_HOST in self link' do
      get '/v0/institutions?name=ABC'
      links = JSON.parse(response.body)['links']
      expect(links['self']).to start_with(ENV['LINK_HOST'])
    end

    it 'allow searching by address fields' do
      institution = create(:institution, address_1: 'address_1', version: Version.current_production.number)
      get(v0_institutions_path(name: 'address_1', include_address: true))
      expect(JSON.parse(response.body)['data'][0]['id'].to_i).to eq(institution.id)
    end
  end

  context '#show' do
    it 'uses LINK_HOST in self link' do
      school = create(:institution, :contains_harv, version: Version.current_production.number)
      get "/v0/institutions/#{school.facility_code}"
      links = JSON.parse(response.body)['links']
      expect(links['self']).to start_with(ENV['LINK_HOST'])
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'

RSpec.describe 'institutions', type: :request do
  before do
    create(:version, :preview)
    create(:version, :production)
  end

  describe '#autocomplete' do
    it 'uses LINK_HOST in self link' do
      create(:institution, :in_chicago, version_id: Version.current_production.id)
      get '/v0/institutions/autocomplete?term=uni'
      links = JSON.parse(response.body)['links']
      expect(links['self']).to start_with(ENV['LINK_HOST'])
    end
  end

  describe '#search' do
    it 'uses LINK_HOST in self link' do
      get '/v0/institutions?name=ABC'
      links = JSON.parse(response.body)['links']
      expect(links['self']).to start_with(ENV['LINK_HOST'])
    end

    it 'allow searching by address fields' do
      institution = create(:institution, physical_address_1: 'address_1', version_id: Version.current_production.id)
      get(v0_institutions_path(name: 'address_1', include_address: true))
      data = JSON.parse(response.body)['data'][0]
      expect(data['id'].to_i).to eq(institution.id)
      expect(data['attributes']['physical_address_1']).to eq('address_1')
    end
  end

  describe '#search v1' do
    it 'searches v1 by name and returns new missions fields' do
      institution = create(:institution, hsi: 1, version_id: Version.current_production.id)
      get '/v1/institutions?name=institution&page=1'
      data = JSON.parse(response.body)['data'][0]
      expect(data['attributes']['hsi']).to eq(1)
    end
  end

  describe '#show' do
    it 'uses LINK_HOST in self link' do
      school = create(:institution, :contains_harv, version_id: Version.current_production.id)
      get "/v0/institutions/#{school.facility_code}"
      links = JSON.parse(response.body)['links']
      expect(links['self']).to start_with(ENV['LINK_HOST'])
    end
  end
end

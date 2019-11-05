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
      create(:institution, :in_chicago)
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
      institution = create(:institution, address_1: 'address_1', version: Version.current_production.number)
      get(v0_institutions_path(name: 'address_1', include_address: true))
      data = JSON.parse(response.body)['data'][0]
      expect(data['id'].to_i).to eq(institution.id)
      expect(data['attributes']['address_1']).to eq('address_1')
    end
  end

  describe '#search vet-tec' do
    def create_vet_tec_institutions
      create(:institution,
             :vet_tec_provider,
             version: Version.current_production.number,
             institution: 'D')
      create(:institution,
             :vet_tec_provider,
             version: Version.current_production.number,
             institution: 'C')
      create(:institution,
             :vet_tec_provider,
             version: Version.current_production.number,
             institution: 'B')
      create(:institution,
             :vet_tec_provider,
             version: Version.current_production.number,
             institution: 'A')
    end

    def institution_name_from_response(body, index)
      JSON.parse(body)['data'][index]['attributes']['name']
    end

    def check_institution_response_order(body)
      expect(institution_name_from_response(body, 0)).to eq('A')
      expect(institution_name_from_response(body, 1)).to eq('B')
      expect(institution_name_from_response(body, 2)).to eq('C')
      expect(institution_name_from_response(body, 3)).to eq('D')
    end

    it 'orders correctly for vet_tec_providers' do
      create_vet_tec_institutions
      get(v0_institutions_path(vet_tec_provider: true))
      check_institution_response_order(response.body)
    end
  end

  describe '#show' do
    it 'uses LINK_HOST in self link' do
      school = create(:institution, :contains_harv, version: Version.current_production.number)
      get "/v0/institutions/#{school.facility_code}"
      links = JSON.parse(response.body)['links']
      expect(links['self']).to start_with(ENV['LINK_HOST'])
    end
  end
end

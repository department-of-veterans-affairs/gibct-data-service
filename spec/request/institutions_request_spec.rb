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
      institution = create(:institution, address_1: 'address_1', version: Version.current_production.number,
                                         approved: true)
      get(v0_institutions_path(name: 'address_1', include_address: true))
      data = JSON.parse(response.body)['data'][0]
      expect(data['id'].to_i).to eq(institution.id)
      expect(data['attributes']['address_1']).to eq('address_1')
    end

    it 'orders correctly for vet_tec_providers' do
      institution_a = create(:institution,
                             :vet_tec_provider,
                             version: Version.current_production.number,
                             institution: 'A')
      institution_b = create(:institution,
                             :vet_tec_provider,
                             version: Version.current_production.number,
                             institution: 'B')
      institution_c = create(:institution,
                             :vet_tec_preferred_provider,
                             version: Version.current_production.number,
                             institution: 'C')
      institution_d = create(:institution,
                             :vet_tec_preferred_provider,
                             version: Version.current_production.number,
                             institution: 'D')
      get(v0_institutions_path(vet_tec_provider: true))

      data_institution_c = JSON.parse(response.body)['data'][0]
      data_institution_d = JSON.parse(response.body)['data'][1]
      data_institution_a = JSON.parse(response.body)['data'][2]
      data_institution_b = JSON.parse(response.body)['data'][3]

      puts data_institution_a

      expect(data_institution_c['attributes']['name']).to eq(institution_c.institution)
      expect(data_institution_d['attributes']['name']).to eq(institution_d.institution)
      expect(data_institution_a['attributes']['name']).to eq(institution_a.institution)
      expect(data_institution_b['attributes']['name']).to eq(institution_b.institution)
    end
  end

  context '#show' do
    it 'uses LINK_HOST in self link' do
      school = create(:institution, :contains_harv, version: Version.current_production.number, approved: true)
      get "/v0/institutions/#{school.facility_code}"
      links = JSON.parse(response.body)['links']
      expect(links['self']).to start_with(ENV['LINK_HOST'])
    end
  end
end

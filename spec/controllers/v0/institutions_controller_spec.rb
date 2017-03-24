# frozen_string_literal: true
require 'rails_helper'

RSpec.describe V0::InstitutionsController, type: :controller do
  context 'autocomplete results' do
    it 'returns collection of matches' do
      create(:version, :production)
      7.times { create(:institution, :contains_harv) }
      get :autocomplete, term: 'harv', version: 1
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'returns empty collection on missing term parameter' do
      create(:version, :production)
      7.times { create(:institution, :contains_harv) }
      get :autocomplete, term: nil, version: 1
      expect(JSON.parse(response.body)['data'].count).to eq(0)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end
  end

  context 'search results' do
    before(:each) do
      create(:version, :production)
      2.times { create(:institution, :in_nyc) }
      create(:institution, :in_chicago)
      create(:institution, :in_new_rochelle)
    end

    it 'search returns results' do
      get :index, version: 1
      expect(JSON.parse(response.body)['data'].count).to eq(4)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search returns results matching name' do
      get :index, name: 'chicago', version: 1
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search returns case-insensitive results' do
      get :index, name: 'CHICAGO', version: 1
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search with space returns results' do
      get :index, name: 'New Roch', version: 1
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filter by uppercase country returns results' do
      get :index, name: 'chicago', country: 'USA', version: 1
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filter by lowercase country returns results' do
      get :index, name: 'chicago', country: 'usa', version: 1
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filter by uppercase state returns results' do
      get :index, name: 'new', state: 'NY', version: 1
      expect(JSON.parse(response.body)['data'].count).to eq(3)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filter by lowercase state returns results' do
      get :index, name: 'new', state: 'ny', version: 1
      expect(JSON.parse(response.body)['data'].count).to eq(3)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'has facet metadata' do
      get :index, name: 'chicago', version: 1
      facets = JSON.parse(response.body)['meta']['facets']
      expect(facets['state']['il']).to eq(1)
      expect(facets['country'].count).to eq(1)
      expect(facets['country'][0]['name']).to eq('USA')
    end
  end

  context 'institution profile' do
    before(:each) do
      create(:version, :production)
    end

    it 'returns profile details' do
      school = create(:institution, :in_chicago)

      get :show, id: school.facility_code, version: school.version
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institution_profile')
    end

    it 'returns common exception response if school not found' do
      get :show, id: '10000'
      assert_response :missing
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('errors')
    end
  end
end

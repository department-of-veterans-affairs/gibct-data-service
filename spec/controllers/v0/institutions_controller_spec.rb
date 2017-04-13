# frozen_string_literal: true
require 'rails_helper'

RSpec.describe V0::InstitutionsController, type: :controller do
  context 'version determination' do
    it 'uses a production version as a default' do
      create(:version, :production)
      create(:institution, :contains_harv)

      get :index
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'accepts invalid version parameter and returns production data' do
      create(:version, :production)
      create(:institution, :contains_harv)

      get :index, version: 'invalid_data'
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
      body = JSON.parse response.body
      expect(body['meta']['version']['number'].to_i).to eq(Version.current_production.number)
    end

    it 'accepts version number as a version parameter and returns preview data' do
      create(:version, :production)
      v = create(:version, :preview)
      create(:institution, :contains_harv, version: Version.current_preview.number)

      get :index, version: v.uuid
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
      body = JSON.parse response.body
      expect(body['meta']['version']['number'].to_i).to eq(Version.current_preview.number)
    end
  end

  context 'autocomplete results' do
    it 'returns collection of matches' do
      create(:version, :production)
      7.times { create(:institution, :contains_harv) }
      get :autocomplete, term: 'harv', version: 'production'
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'returns empty collection on missing term parameter' do
      create(:version, :production)
      7.times { create(:institution, :contains_harv) }
      get :autocomplete, term: nil, version: 'production'
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
      get :index, version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(4)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search returns results matching name' do
      get :index, name: 'chicago', version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search returns case-insensitive results' do
      get :index, name: 'CHICAGO', version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search with space returns results' do
      get :index, name: 'New Roch', version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filter by uppercase country returns results' do
      get :index, name: 'chicago', country: 'USA', version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filter by lowercase country returns results' do
      get :index, name: 'chicago', country: 'usa', version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filter by uppercase state returns results' do
      get :index, name: 'new', state: 'NY', version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(3)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filter by lowercase state returns results' do
      get :index, name: 'new', state: 'ny', version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(3)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'has facet metadata' do
      get :index, name: 'chicago', version: 'production'
      facets = JSON.parse(response.body)['meta']['facets']
      expect(facets['state']['il']).to eq(1)
      expect(facets['country'].count).to eq(1)
      expect(facets['country'][0]['name']).to eq('USA')
    end
  end

  context 'category and type search results' do
    before(:each) do
      create(:version, :production)
      create(:institution, :in_nyc)
      create(:institution, :ca_employer)
    end

    it 'filters by employer category' do
      get :index, category: 'employer', version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filters by school category' do
      get :index, category: 'school', version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filters by employer type' do
      get :index, type: 'ojt', version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filters by school type' do
      get :index, type: 'private', version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
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

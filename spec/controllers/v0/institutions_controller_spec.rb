# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V0::InstitutionsController, type: :controller do
  context 'version determination' do
    it 'uses a production version as a default' do
      create(:version, :production)
      create(:institution, :contains_harv, approved: true)
      get :index
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'accepts invalid version parameter and returns production data' do
      create(:version, :production)
      create(:institution, :contains_harv, approved: true)
      get :index, version: 'invalid_data'
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
      body = JSON.parse response.body
      expect(body['meta']['version']['number'].to_i).to eq(Version.current_production.number)
    end

    it 'accepts version number as a version parameter and returns preview data' do
      create(:version, :production)
      v = create(:version, :preview)
      create(:institution, :contains_harv, approved: true, version: Version.current_preview.number)
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
      7.times { create(:institution, :contains_harv, approved: true) }
      get :autocomplete, term: 'harv', version: 'production'
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'returns empty collection on missing term parameter' do
      create(:version, :production)
      create(:institution, :contains_harv, approved: false)
      get :autocomplete, term: nil, version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(0)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'does not return results for non-approved institutions' do
      create(:version, :production)
      create(:institution, :contains_harv, approved: false)
      get :autocomplete, term: 'harv', version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(0)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end
  end

  context 'search results' do
    before(:each) do
      create(:version, :production)
      2.times { create(:institution, :in_nyc, approved: true) }
      create(:institution, :in_chicago, online_only: true, approved: true)
      create(:institution, :in_new_rochelle, distance_learning: true, approved: true)
      # adding a non approved institutions row
      create(:institution, :contains_harv, approved: false)
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

    it 'filters by online_only schools' do
      get :index, online_only: true, version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(1)
    end

    it 'filters by distance_learning schools' do
      get :index, distance_learning: true, version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(1)
    end

    it 'filters by vet_tec_provider schools' do
      create(:institution, :vet_tec_provider)
      create(:institution, :vet_tec_provider, vet_tec_provider: false)
      get :index, vet_tec_provider: true, version: 'production'
      expect(JSON.parse(response.body)['data'].count).to eq(1)
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

    it 'includes type search term in facets' do
      get :index, name: 'chicago', type: 'foreign'
      facets = JSON.parse(response.body)['meta']['facets']
      expect(facets['type']['foreign']).not_to be_nil
      expect(facets['type']['foreign']).to eq(0)
    end

    it 'includes state search term in facets' do
      get :index, name: 'chicago', state: 'WY'
      facets = JSON.parse(response.body)['meta']['facets']
      expect(facets['state']['wy']).not_to be_nil
      expect(facets['state']['wy']).to eq(0)
    end

    it 'includes country search term in facets' do
      get :index, name: 'chicago', country: 'france'
      facets = JSON.parse(response.body)['meta']['facets']
      match = facets['country'].select { |c| c['name'] == 'FRANCE' }.first
      expect(match).not_to be nil
      expect(match['count']).to eq(0)
    end

    it 'includes boolean facets' do
      get :index
      facets = JSON.parse(response.body)['meta']['facets']
      expect(facets['student_vet_group'].keys).to include('true', 'false')
      expect(facets['yellow_ribbon_scholarship'].keys).to include('true', 'false')
      expect(facets['principles_of_excellence'].keys).to include('true', 'false')
      expect(facets['eight_keys_to_veteran_success'].keys).to include('true', 'false')
      expect(facets['stem_offered'].keys).to include('true', 'false')
      expect(facets['independent_study'].keys).to include('true', 'false')
      expect(facets['priority_enrollment'].keys).to include('true', 'false')
      expect(facets['online_only'].keys).to include('true', 'false')
      expect(facets['distance_learning'].keys).to include('true', 'false')
    end
  end

  context 'category and type search results' do
    before(:each) do
      create(:version, :production)
      create(:institution, :in_nyc, approved: true)
      create(:institution, :ca_employer, approved: true)
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
      school = create(:institution, :in_chicago, approved: true)
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

  context 'institution children' do
    before(:each) do
      create(:version, :production)
    end

    it 'returns institution children' do
      school = create(:institution, :in_chicago)
      child_school = create(:institution, :in_chicago, parent_facility_code_id: school.facility_code)

      get :children, id: school.facility_code, version: school.version

      expect(response.content_type).to eq('application/json')
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['attributes']['facility_code']).to eq(child_school.facility_code)
      expect(JSON.parse(response.body)['data'][0]['attributes']['parent_facility_code_id']).to eq(school.facility_code)
      expect(response).to match_response_schema('institutions')
    end

    it 'returns common exception response if child institutions not found' do
      get :children, id: '10000'

      expect(response.content_type).to eq('application/json')
      expect(JSON.parse(response.body)['data'].count).to eq(0)
    end
  end
end

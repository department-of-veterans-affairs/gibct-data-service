# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V0::YellowRibbonProgramsController, type: :controller do
  context 'when determining version' do
    it 'uses a production version as a default' do
      create(:version, :production)
      create(:yellow_ribbon_program)
      get(:index)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'accepts invalid version parameter and returns production data' do
      create(:version, :production)
      create(:yellow_ribbon_program)
      get(:index, params: { version: 'invalid_data' })
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
      body = JSON.parse response.body
      expect(body['meta']['version']['number'].to_i).to eq(Version.current_production.number)
    end
  end

  context 'when searching' do
    before do
      create(:version, :production)
      create_list(:yellow_ribbon_program, 3)
      create(:yellow_ribbon_program, :in_florence)
    end

    it 'search returns results' do
      get(:index)
      expect(JSON.parse(response.body)['data'].count).to eq(4)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'search returns results matching school_name_in_yr_database' do
      get(:index, params: { school_name_in_yr_database: 'Future' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'search returns case-insensitive results' do
      get(:index, params: { school_name_in_yr_database: 'FUTURE' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'search with space returns results' do
      get(:index, params: { school_name_in_yr_database: 'Future Tech' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'search returns results ordered by number_of_students desc' do
      get(:index, params: { sort_by: 'number_of_students', sort_direction: 'desc' })
      expect(JSON.parse(response.body)['data'].last['attributes']['number_of_students']).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'search returns case-insensitive results' do
      get(:index, params: { sort_by: 'Number_of_Students', sort_direction: 'desc' })
      expect(JSON.parse(response.body)['data'].last['attributes']['number_of_students']).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'search with space returns results' do
      get(:index, params: { sort_by: ' number_of_students ', sort_direction: 'desc' })
      expect(JSON.parse(response.body)['data'].last['attributes']['number_of_students']).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'search with invalid sorting query params' do
      get(:index, params: { sort_by: 'asdf', sort_direction: 'asdf' })
      expect(JSON.parse(response.body)['data'].count).to eq(4)
      expect(JSON.parse(response.body)['data'].first['attributes']['school_name_in_yr_database']).to eq('Future Tech University')
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end
  end
end

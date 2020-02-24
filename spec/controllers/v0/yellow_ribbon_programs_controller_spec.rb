# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V0::YellowRibbonProgramsController, type: :controller do
  context 'when determining version' do
    it 'uses a production version as a default' do
      create(:version, :production)
      create(:yellow_ribbon_program_source)
      get(:index)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program_source')
    end

    it 'accepts invalid version parameter and returns production data' do
      create(:version, :production)
      create(:yellow_ribbon_program_source)
      get(:index, params: { version: 'invalid_data' })
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program_source')
      body = JSON.parse response.body
      expect(body['meta']['version']['number'].to_i).to eq(Version.current_production.number)
    end
  end

  context 'when searching' do
    before do
      create(:version, :production)
      create_list(:yellow_ribbon_program_source, 3)
      create(:yellow_ribbon_program_source, :in_florence)
    end

    it 'search returns results' do
      get(:index)
      expect(JSON.parse(response.body)['data'].count).to eq(4)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program_source')
    end

    it 'search returns results matching school_name_in_yr_database' do
      get(:index, params: { name: 'Future' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program_source')
    end

    it 'search returns case-insensitive results' do
      get(:index, params: { name: 'FUTURE' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program_source')
    end

    it 'search with space returns results' do
      get(:index, params: { name: 'Future Tech' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program_source')
    end
  end
end

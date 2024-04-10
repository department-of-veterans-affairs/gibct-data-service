# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V0::YellowRibbonProgramsController, type: :controller do
  def create_prod_version_and_institution
    create(:version, :production, :with_institution)
    [Version.last, Institution.last]
  end

  def create_previw_version_and_institution
    create(:version, :preview, :with_institution)
    [Version.last, Institution.last]
  end

  context 'when determining version' do
    it 'uses a production version as a default' do
      v1, i1 = create_prod_version_and_institution
      v2, i2 = create_previw_version_and_institution
      create(:yellow_ribbon_program, version: v1.number, institution_id: i1.id)
      create(:yellow_ribbon_program, version: v2.number, institution_id: i2.id)
      get(:index)
      body = JSON.parse response.body
      expect(body['data'].count).to eq(1)
    end

    it 'accepts invalid version parameter and returns production data' do
      v, i = create_prod_version_and_institution
      create(:yellow_ribbon_program, version: v.number, institution_id: i.id)
      get(:index, params: { version: 'invalid_data' })
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
      body = JSON.parse response.body
      expect(body['meta']['version']['number'].to_i).to eq(Version.current_production.number)
    end
  end

  context 'when searching' do
    before do
      v, i = create_prod_version_and_institution
      create_list(:yellow_ribbon_program, 3, version: v.number, institution_id: i.id)
      create(:yellow_ribbon_program, :in_florence, version: v.number, institution_id: i.id)
    end

    it 'search returns results' do
      get(:index)
      data = JSON.parse(response.body)['data']
      expect(data.count).to eq(4)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'search returns results matching name' do
      get(:index, params: { name: 'institution' })
      data = JSON.parse(response.body)['data']
      expect(data.count).to eq(4)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'search returns case-insensitive results' do
      get(:index, params: { name: 'INSTITUTION ' })
      data = JSON.parse(response.body)['data']
      expect(data.count).to eq(4)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'search with space returns results' do
      get(:index, params: { name: 'institution ' })
      data = JSON.parse(response.body)['data']
      expect(data.count).to eq(4)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'search returns results ordered by number_of_students desc' do
      get(:index, params: { sort_by: 'number_of_students', sort_direction: 'desc' })
      data = JSON.parse(response.body)['data']
      expect(data.last['attributes']['number_of_students']).to eq(1)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'search returns case-insensitive results for sorting query params' do
      get(:index, params: { sort_by: 'Number_of_Students', sort_direction: 'DESC' })
      data = JSON.parse(response.body)['data']
      expect(data.last['attributes']['number_of_students']).to eq(1)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'search with space in sorting query params returns results' do
      get(:index, params: { sort_by: ' number_of_students ', sort_direction: 'desc' })
      data = JSON.parse(response.body)['data']
      expect(data.last['attributes']['number_of_students']).to eq(1)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'search with invalid sorting query params' do
      get(:index, params: { sort_by: 'asdf', sort_direction: 'asdf' })
      data = JSON.parse(response.body)['data']
      expect(data.count).to eq(4)
      expect(data.first['attributes']['name_of_institution']).to include('institution ')
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('yellow_ribbon_program')
    end

    it 'respects `per_page`' do
      get(:index, params: { per_page: 2 })
      data = JSON.parse(response.body)['data']
      expect(data.count).to eq(2)
    end
  end
end

# frozen_string_literal: true
require 'rails_helper'

RSpec.describe V0::InstitutionsController, type: :controller do
  context 'autocomplete results' do
    it 'returns collection of matches' do
      7.times { create(:institution, :contains_harv) }
      get :autocomplete, term: 'harv'
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end
  end

  context 'search results' do
    it 'search returns results' do
      get :index
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end
  end

  context 'institution profile' do
    it 'returns profile details' do
      school = create(:institution, :in_chicago)
      get :show, id: school.facility_code
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

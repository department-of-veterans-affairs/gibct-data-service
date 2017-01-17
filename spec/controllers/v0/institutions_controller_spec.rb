# frozen_string_literal: true
require 'rails_helper'

RSpec.describe V0::InstitutionsController, type: :controller do
  context 'autocomplete results' do
    it 'returns collection of matches' do
      get :autocomplete, term: 'harv'
      assert_response :success
      expect(response.content_type).to eq('application/json')
    end
  end

  context 'search results' do
    it 'search returns results' do
      get :index
      assert_response :success
      expect(response.content_type).to eq('application/json')
    end
  end

  context 'institution profile' do
    xit 'returns common exception response if school not found' do
      get :show, id: '1'
      assert_response :missing
      expect(response.content_type).to eq('application/json')
    end
  end
end

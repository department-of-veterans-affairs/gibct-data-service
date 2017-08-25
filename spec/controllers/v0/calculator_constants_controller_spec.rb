# frozen_string_literal: true
require 'rails_helper'

RSpec.describe V0::CalculatorConstantsController, type: :controller do
  describe 'GET #index' do
    it 'returns calculator constants' do
      2.times { create(:calculator_constant) }
      create(:version, :production)
      get :index
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('calculator_constants')
    end
  end
end

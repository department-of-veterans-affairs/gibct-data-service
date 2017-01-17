# frozen_string_literal: true
require 'rails_helper'

RSpec.describe V0::CalculatorConstantsController, type: :controller do
  describe 'GET #index' do
    it 'returns calculator constants' do
      get :index
      assert_response :success
      expect(response.content_type).to eq('application/json')
    end
  end
end

# frozen_string_literal: true
require 'rails_helper'
require 'json'

RSpec.describe StatusController, type: :controller do
  describe 'GET #status' do
    it 'returns ok' do
      get :status
      expect(response.content_type).to eq('application/json')
      expect(JSON.parse(response.body)['status']).to eq('ok')
    end
  end
end

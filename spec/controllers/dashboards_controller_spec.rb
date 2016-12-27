# frozen_string_literal: true
require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'
require 'controllers/shared_examples/shared_examples_for_alertable'

RSpec.describe DashboardsController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'dashboards'
  it_behaves_like 'an alertable controller'

  describe 'GET #index' do
    login_user

    before(:each) do
      create :version, version: 1
      create :version, :production, version: 2
      create :version, version: 3

      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'provides latest production and preview viewsons' do
      expect(assigns(:production_version).version).to eq(2)
      expect(assigns(:preview_version).version).to eq(3)
    end
  end
end

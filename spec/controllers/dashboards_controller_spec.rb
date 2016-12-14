# frozen_string_literal: true
require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe DashboardsController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'dashboards'

  describe 'GET #index' do
    login_user

    before(:each) do
      create :version, number: 1
      create :version, :as_production, number: 2
      create :version, number: 3

      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'provides latest production and preview viewsons' do
      expect(assigns(:production_version)).to eq(2)
      expect(assigns(:preview_version)).to eq(3)
    end
  end
end

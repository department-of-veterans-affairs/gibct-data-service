# frozen_string_literal: true
require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe UploadsController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'uploads'

  describe 'GET index' do
    login_user

    before(:each) do
      create :upload
      get :index
    end

    it 'populates an array of uploads' do
      expect(assigns(:uploads)).to include(Upload.first)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end

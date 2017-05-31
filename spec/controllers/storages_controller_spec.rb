# frozen_string_literal: true
require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe StoragesController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'storages'

  describe 'GET index' do
    login_user

    before(:each) do
      create :storage
      get :index
    end

    it 'populates an array of uploads' do
      expect(assigns(:storages)).to include(Storage.first)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET download' do
    login_user

    let(:storage) { create :storage }

    context 'with a valid id' do
      before(:each) do
        get :download, id: storage.id
      end

      it 'gets the storage' do
        expect(assigns(:storage)).to eq(storage)
      end
    end

    context 'with an invalid id' do
      it 'generates an alert message' do
        get :download, id: 1_000_000
        expect(flash[:alert]).to match 'Invalid Storage id: 1000000'
      end
    end
  end
end

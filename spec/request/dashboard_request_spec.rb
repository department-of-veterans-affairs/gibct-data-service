# frozen_string_literal: true
require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'

RSpec.describe 'Dashboard', type: :request do
  before(:each) do
    user = User.create!(email: 'testuser@va.gov', password: 'secretshh')
    login_as(user, scope: :user)
  end

  it 'responds to POST #build with errors if no uploads' do
    post dashboard_build_path
    expect(response).to redirect_to('/dashboards')
    expect(flash[:alert]).to match 'Cannot build a new version since no new uploads have been made.'
  end

  it 'responds to POST #build with success' do
    allow(Version).to receive(:buildable?).and_return(true)
    post dashboard_build_path
    expect(response).to redirect_to('/dashboards')
    expect(flash[:notice]).to match 'Preview Data (1) built successfully'
  end

  it 'responds to POST #push' do
    post dashboard_push_path
    expect(response).to have_http_status(:found)
  end

  it 'does not respond to GET #build' do
    expect do
      get dashboard_build_path
    end.to raise_error(ActionController::RoutingError)
  end

  it 'does not respond to GET #push' do
    expect do
      get dashboard_push_path
    end.to raise_error(ActionController::RoutingError)
  end
end

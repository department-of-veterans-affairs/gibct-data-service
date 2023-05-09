# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'

RSpec.describe 'Dashboard', type: :request do
  before do
    user = User.create!(email: 'testuser@va.gov', password: 'secretshh')
    login_as(user, scope: :user)
    allow(VetsApi::Service).to receive(:feature_enabled?).and_return(false)
  end

  it 'responds to POST #build with redirect' do
    create(:version, :production)
    post dashboard_build_path
    expect(response).to redirect_to('/dashboards')
  end

  it 'does not respond to GET #build' do
    expect do
      get dashboard_build_path
    end.to raise_error(ActionController::RoutingError)
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe CrosswalksController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'crosswalks'

  describe 'GET #index' do
    login_user

    before do
      create_list :crosswalk_issue, 3
      get(:index)
    end

    it 'populates an array of crosswalk issues' do
      expect(assigns(:issues).length).to eq(CrosswalkIssue.count)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end

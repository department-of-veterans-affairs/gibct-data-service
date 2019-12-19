# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe CrosswalksController, type: :controller do
  it_behaves_like 'an authenticating controller', :weams, 'crosswalks'

  describe 'GET #weams' do
    login_user

    before do
      create_list :crosswalk_issue, 3, :weams_source
      create_list :crosswalk_issue, 2, :ipeds_hd_source
      get(:weams)
    end

    it 'populates an array of crosswalk issues' do
      expect(assigns(:issues).length).to eq(CrosswalkIssue.issue_source(CrosswalkIssue::WEAMS_SOURCE).count)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #ipeds' do
    login_user

    before do
      create_list :crosswalk_issue, 3, :weams_source
      create_list :crosswalk_issue, 2, :ipeds_hd_source
      get(:ipeds)
    end

    it 'populates an array of crosswalk issues' do
      expect(assigns(:issues).length).to eq(CrosswalkIssue.issue_source(CrosswalkIssue::IPEDS_HDS_SOURCE).count)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end

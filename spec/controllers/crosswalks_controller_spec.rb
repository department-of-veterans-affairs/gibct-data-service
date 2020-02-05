# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe CrosswalksController, type: :controller do
  it_behaves_like 'an authenticating controller', :partials, 'crosswalks'

  describe 'GET #partials' do
    login_user

    before do
      create_list :crosswalk_issue, 3, :partial_match_type, :with_weam_match
      create_list :crosswalk_issue, 2, :ipeds_orphan_type
      get(:partials)
    end

    it 'populates an array of crosswalk issues' do
      expect(assigns(:issues).length).to eq(CrosswalkIssue.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'orders by arf_gi_bill.gibill' do
      issues = assigns(:issues)
      issues_last = issues[issues.length - 1]
      expect(issues.first.weam.arf_gi_bill.gibill).to be > issues_last.weam.arf_gi_bill.gibill
    end
  end

  describe 'GET #orphans' do
    login_user

    before do
      create_list :crosswalk_issue, 3, :partial_match_type
      create_list :crosswalk_issue, 2, :ipeds_orphan_type
      get(:orphans)
    end

    it 'populates an array of crosswalk issues' do
      expect(assigns(:issues).length).to eq(CrosswalkIssue.by_issue_type(CrosswalkIssue::IPEDS_ORPHAN_TYPE).count)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end

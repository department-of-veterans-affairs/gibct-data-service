# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe CrosswalkIssuesController, type: :controller do
  it_behaves_like 'an authenticating controller', :partials, 'crosswalk_issues'

  describe 'GET #partials' do
    login_user

    before do
      create_list :crosswalk_issue, 3, :partial_match_type, :with_weam_match
      create_list :crosswalk_issue, 2, :ipeds_orphan_type
      get(:partials)
    end

    it 'populates an array of crosswalk issues' do
      expect(assigns(:issues).all.map { |a| a[:issue_type] }).to all(eq(CrosswalkIssue::PARTIAL_MATCH_TYPE))
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

  describe 'GET #show_partial' do
    login_user

    before do
      create_list :crosswalk_issue, 3, :partial_match_type, :with_weam_match_partial
    end

    it 'returns http success' do
      get(:show_partial, params: { id: CrosswalkIssue.first[:id] })
      expect(response).to have_http_status(:success)
    end

    it 'returns issue' do
      get(:show_partial, params: { id: CrosswalkIssue.first[:id] })
      expect(assigns(:issue)).not_to be_nil
    end

    context 'when matching ipeds_hd to weam' do
      before do
        create :ipeds_hd, cross: 'r', ope: 's',
                          institution: 'college of nowhere',
                          city: 'NA', state: 'SC', zip: '99999'
        create :ipeds_hd, cross: 't', ope: 'u',
                          institution: 'college of', city: 'Test',
                          state: 'TN', zip: '99999'
        create :ipeds_hd, cross: 'w', ope: 'x',
                          institution: 'college of', city: 'nowhere',
                          state: 'CA', zip: '88888'
      end

      it 'populates an array of Ipeds_hds possible matches with state matching weams state' do
        issue = create :crosswalk_issue, :with_weam_match_partial, :partial_match_type
        get(:show_partial, params: { id: issue.id })
        expect(assigns(:possible_ipeds_matches).map { |match| match['state'] }).to all(eq(issue.weam.state))
        expect(assigns(:possible_ipeds_matches).count).to eq(1)
      end

      it 'populates an array of Ipeds_hds with state matching weams physical state' do
        issue = create :crosswalk_issue, :with_weam_match_partial_physical_ca, :partial_match_type
        get(:show_partial, params: { id: issue.id })
        expect(assigns(:possible_ipeds_matches).map { |match| match['state'] }).to all(eq(issue.weam.physical_state))
        expect(assigns(:possible_ipeds_matches).count).to eq(1)
      end

      it 'populates an array of Ipeds_hds possible matches ordered by match amount' do
        best_match = create :ipeds_hd, cross: 'aa', ope: 'dd',
                                       institution: 'COLLEGE OF NOWHERE', city: 'test',
                                       state: 'CA', zip: '88888'
        issue = create :crosswalk_issue, :with_weam_match_partial_physical_ca, :partial_match_type
        get(:show_partial, params: { id: issue.id })
        expect(assigns(:possible_ipeds_matches).first['id']).to eq(best_match['id'])
        expect(assigns(:possible_ipeds_matches).count).to eq(2)
      end

      it 'calculates full name and address match correctly' do
        best_match = create :ipeds_hd, cross: 'aa', ope: 'dd',
                                       institution: 'COLLEGE OF NOWHERE', city: 'test',
                                       state: 'TN', zip: '99999'
        issue = create :crosswalk_issue, :with_weam_match_partial, :partial_match_type
        get(:show_partial, params: { id: issue.id })
        expect(assigns(:possible_ipeds_matches).first['match_score']).to eq(1.0)
        expect(assigns(:possible_ipeds_matches).first['id']).to eq(best_match['id'])
      end

      it 'calculates full name and physical address match correctly' do
        best_match = create :ipeds_hd, cross: 'aa', ope: 'dd',
                                       institution: 'COLLEGE OF NOWHERE', city: 'test',
                                       addr: '123 test st', state: 'CA', zip: '9999'
        issue = create :crosswalk_issue, :with_weam_match_partial_physical_ca, :partial_match_type
        get(:show_partial, params: { id: issue.id })
        expect(assigns(:possible_ipeds_matches).first['match_score']).to eq(1.0)
        expect(assigns(:possible_ipeds_matches).first['id']).to eq(best_match['id'])
      end

      it 'calculates name witout address match correctly correctly' do
        best_match = create :ipeds_hd, cross: 'aa', ope: 'dd',
                                       institution: 'COLLEGE OF NOWHERE', city: 'Houston',
                                       state: 'CA', zip: '11111'
        issue = create :crosswalk_issue, :with_weam_match_partial_physical_ca, :partial_match_type
        get(:show_partial, params: { id: issue.id })
        expect(assigns(:possible_ipeds_matches).first['match_score']).to eq(0.5)
        expect(assigns(:possible_ipeds_matches).first['id']).to eq(best_match['id'])
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #resolve_partial' do
    login_user

    context 'when related Crosswalk does not exist' do
      let(:issue) { create :crosswalk_issue, :partial_match_type, :with_weam_match }
      let(:weam) { CrosswalkIssue.find(params[:id]).weam }
      let(:crosswalk) { CrosswalkIssue.find(params[:id]).crosswalk }

      let(:params) do
        {
          id: issue.id,
          cross: '44445555',
          ope: '333666',
          notes: 'test'
        }
      end

      it 'correctly updates Crosswalk fields from params' do
        expect { post(:resolve_partial, params: params) }.to change(Crosswalk, :count).from(0).to(1)
        expect(crosswalk[:cross]).to eq(params[:cross])
        expect(crosswalk[:ope]).to eq(params[:ope])
        expect(crosswalk[:notes]).to eq(params[:notes])
      end

      it 'correctly updates Crosswalk fields from weams' do
        expect { post(:resolve_partial, params: params) }.to change(Crosswalk, :count).from(0).to(1)
        expect(crosswalk[:facility_code]).to eq(weam[:facility_code])
        expect(crosswalk[:institution]).to eq(weam[:institution])
        expect(crosswalk[:city]).to eq(weam[:city])
        expect(crosswalk[:state]).to eq(weam[:state])
      end
    end

    context 'when related Crosswalk exists' do
      let(:issue) { create :crosswalk_issue, :partial_match_type, :with_weam_match, :with_crosswalk_match }
      let(:weam) { CrosswalkIssue.find(params[:id]).weam }
      let(:crosswalk) { CrosswalkIssue.find(params[:id]).crosswalk }

      let(:params) do
        {
          id: issue.id,
          cross: '44445555',
          ope: '333666',
          notes: 'test'
        }
      end

      it 'does not update crosswalk_id' do
        expect { post(:resolve_partial, params: params) }.not_to change { issue[:crosswalk_id] }
      end

      it 'correctly updates Crosswalk fields from params' do
        post(:resolve_partial, params: params)
        expect(crosswalk[:cross]).to eq(params[:cross])
        expect(crosswalk[:ope]).to eq(params[:ope])
        expect(crosswalk[:notes]).to eq(params[:notes])
      end

      it 'correctly updates Crosswalk fields from weams' do
        post(:resolve_partial, params: params)
        expect(crosswalk[:facility_code]).to eq(weam[:facility_code])
        expect(crosswalk[:institution]).to eq(weam[:institution])
        expect(crosswalk[:city]).to eq(weam[:city])
        expect(crosswalk[:state]).to eq(weam[:state])
      end
    end

    context 'when Crosswalk is resolved' do
      let(:issue) { create :crosswalk_issue, :partial_match_type, :with_weam_match, :with_ipeds_hd_match }

      let(:params) do
        {
          id: issue.id,
          cross: issue.weam[:cross],
          ope: issue.weam[:ope]
        }
      end

      it 'is deleted' do
        post(:resolve_partial, params: params)
        expect(CrosswalkIssue.exists?(issue.id)).to eq(false)
      end
    end

    context 'when Crosswalk is not resolved' do
      let(:issue) { create :crosswalk_issue, :partial_match_type, :with_weam_match }

      let(:params) do
        {
          id: issue.id,
          cross: issue.weam[:cross],
          ope: issue.weam[:ope]
        }
      end

      it 'is not deleted' do
        post(:resolve_partial, params: params)
        expect(CrosswalkIssue.exists?(issue.id)).to eq(true)
      end
    end

    context 'when Crosswalk is manually resolved' do
      let(:issue) { create :crosswalk_issue, :partial_match_type, :with_weam_match }

      let(:params) do
        {
          id: issue.id,
          cross: issue.weam[:cross],
          ope: issue.weam[:ope],
          ignore: '1'
        }
      end

      it 'is deleted' do
        post(:resolve_partial, params: params)
        expect(CrosswalkIssue.exists?(issue.id)).to eq(false)
      end

      it 'creates IgnoredCrosswalkIssue' do
        expect { post(:resolve_partial, params: params) }
          .to change(IgnoredCrosswalkIssue, :count).from(0).to(1)
      end
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
      expect(assigns(:issues).all.map { |a| a[:issue_type] }).to all(eq(CrosswalkIssue::IPEDS_ORPHAN_TYPE))
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end

# frozen_string_literal: true

RSpec.describe CrosswalkIssue, type: :model do

  describe 'accessors' do
    it 'return weam fields' do
      issue = create :crosswalk_issue, :with_weam_match
      expect(issue.weam_ipeds).not_to eq(nil)
      expect(issue.weam_ope).not_to eq(nil)
      expect(issue.institution_name).not_to eq(nil)
      expect(issue.facility_code).not_to eq(nil)
    end

    it 'returns ipeds_hd fields' do
      issue = create :crosswalk_issue, :with_ipeds_hd_match
      expect(issue.ipeds_hd_ipeds).not_to eq(nil)
      expect(issue.ipeds_hd_ope).not_to eq(nil)
    end

    it 'returns crosswalk fields' do
      issue = create :crosswalk_issue, :with_crosswalk_match
      expect(issue.crosswalk_ipeds).not_to eq(nil)
      expect(issue.crosswalk_ope).not_to eq(nil)
    end
  end

  describe 'when building' do
    it 'matches NCD weams and ipeds_hds by cross (IPEDS)' do
      create :weam, :ncd, :crosswalk_issue_matchable_by_cross
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross

      expect { described_class.rebuild }.to change(described_class, :count).from(0).to(1)
    end

    it 'matches IHL weams and ipeds_hds by cross (IPEDS)' do
      create :weam, :higher_learning, :crosswalk_issue_matchable_by_cross
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross

      expect { described_class.rebuild }.to change(described_class, :count).from(0).to(1)
    end

    it 'matches NCD weams and ipeds_hds on institution name' do
      create :weam, :ncd, :crosswalk_issue_matchable_by_institution
      create :ipeds_hd, :crosswalk_issue_matchable_by_institution

      expect { described_class.rebuild }.to change(described_class, :count).from(0).to(1)
    end

    it 'matches IHL weams and ipeds_hds on institution name' do
      create :weam, :higher_learning, :crosswalk_issue_matchable_by_institution
      create :ipeds_hd, :crosswalk_issue_matchable_by_institution

      expect { described_class.rebuild }.to change(described_class, :count).from(0).to(1)
    end

    it 'matches NCD weams and ipeds_hds on ope' do
      create :weam, :ncd, :crosswalk_issue_matchable_by_ope
      create :ipeds_hd, :crosswalk_issue_matchable_by_ope

      expect { described_class.rebuild }.to change(described_class, :count).from(0).to(1)
    end

    it 'matches IHL weams and ipeds_hds on ope' do
      create :weam, :higher_learning, :crosswalk_issue_matchable_by_ope
      create :ipeds_hd, :crosswalk_issue_matchable_by_ope

      expect { described_class.rebuild }.to change(described_class, :count).from(0).to(1)
    end

    it 'matches NCD weams and crosswalks on facility_code' do
      create :weam, :ncd, :crosswalk_issue_matchable_by_facility_code
      create :crosswalk, :crosswalk_issue_matchable_by_facility_code

      expect { described_class.rebuild }.to change(described_class, :count).from(0).to(1)
    end

    it 'matches IHL weams and crosswalks on facility_code' do
      create :weam, :higher_learning, :crosswalk_issue_matchable_by_facility_code
      create :crosswalk, :crosswalk_issue_matchable_by_facility_code

      expect { described_class.rebuild }.to change(described_class, :count).from(0).to(1)
    end

    it 'excludes non-NCD and non-IHL weams and ipeds_hds by cross (IPEDS)' do
      create :weam, :crosswalk_issue_matchable_by_cross
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross
      described_class.rebuild
      expect(described_class.count).to eq(0)
    end

    it 'excludes institution name matches when all cross and ope are null' do
      create :weam, :ncd, :crosswalk_issue_matchable_by_institution, ope: nil
      create :ipeds_hd, :crosswalk_issue_matchable_by_institution
      create :crosswalk
      described_class.rebuild
      expect(described_class.count).to eq(0)
    end

    it 'excludes cases where cross field matches across all tables' do
      create :weam, :ncd, :crosswalk_issue_matchable_by_institution,
             :crosswalk_issue_matchable_by_facility_code, :crosswalk_issue_matchable_by_cross
      create :ipeds_hd, :crosswalk_issue_matchable_by_institution, :crosswalk_issue_matchable_by_cross
      create :crosswalk, :crosswalk_issue_matchable_by_facility_code, cross: '888888'
      described_class.rebuild
      expect(described_class.count).to eq(0)
    end

    it 'excludes extension weams' do
      create :weam, :ncd, :crosswalk_issue_matchable_by_cross, :extension_campus_type
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross

      described_class.rebuild
      expect(described_class.count).to eq(0)
    end
  end
end

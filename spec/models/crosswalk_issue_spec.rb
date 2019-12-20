# frozen_string_literal: true

RSpec.describe CrosswalkIssue, type: :model do
  describe 'when building partial matches' do
    it 'matches NCD weams and ipeds_hds by cross (IPEDS)' do
      create :weam, :ncd, :crosswalk_issue_matchable_by_cross
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)
    end

    it 'matches IHL weams and ipeds_hds by cross (IPEDS)' do
      create :weam, :higher_learning, :crosswalk_issue_matchable_by_cross
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)
    end

    it 'matches NCD weams and ipeds_hds on ope' do
      create :weam, :ncd, :crosswalk_issue_matchable_by_ope
      create :ipeds_hd, :crosswalk_issue_matchable_by_ope

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)
    end

    it 'matches IHL weams and ipeds_hds on ope' do
      create :weam, :higher_learning, :crosswalk_issue_matchable_by_ope
      create :ipeds_hd, :crosswalk_issue_matchable_by_ope

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)
    end

    it 'matches NCD weams and crosswalks on facility_code' do
      create :weam, :ncd, :crosswalk_issue_matchable_by_facility_code
      create :crosswalk, :crosswalk_issue_matchable_by_facility_code

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)
    end

    it 'matches IHL weams and crosswalks on facility_code' do
      create :weam, :higher_learning, :crosswalk_issue_matchable_by_facility_code
      create :crosswalk, :crosswalk_issue_matchable_by_facility_code

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)
    end

    it 'excludes non-NCD and non-IHL weams and ipeds_hds by cross (IPEDS)' do
      create :weam, :crosswalk_issue_matchable_by_cross
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross
      described_class.rebuild
      expect(described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count).to eq(0)
    end

    it 'excludes cases where cross field matches across all tables' do
      create :weam, :ncd, :crosswalk_issue_matchable_by_facility_code, :crosswalk_issue_matchable_by_cross
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross
      create :crosswalk, :crosswalk_issue_matchable_by_facility_code, cross: '888888'
      described_class.rebuild
      expect(described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count).to eq(0)
    end

    it 'excludes extension weams' do
      create :weam, :ncd, :crosswalk_issue_matchable_by_cross, :extension_campus_type
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross

      described_class.rebuild
      expect(described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count).to eq(0)
    end
  end

  describe 'when building IPEDS orphans' do
    it 'excludes IpedsHD that match Crosswalk by cross (IPEDS)' do
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross
      create :crosswalk, :crosswalk_issue_matchable_by_cross

      expect(described_class.by_issue_type(CrosswalkIssue::IPEDS_ORPHAN_TYPE).count).to eq(0)
    end

    it 'excludes IpedsHD that match Crosswalk by ope' do
      create :ipeds_hd, :crosswalk_issue_matchable_by_ope
      create :crosswalk, :crosswalk_issue_matchable_by_ope

      expect(described_class.by_issue_type(CrosswalkIssue::IPEDS_ORPHAN_TYPE).count).to eq(0)
    end

    it 'includes orphan IpedsHD' do
      create :ipeds_hd
      create :crosswalk

      expect { described_class.rebuild }
          .to change { described_class.by_issue_type(CrosswalkIssue::IPEDS_ORPHAN_TYPE).count }.from(0).to(1)
    end
  end
end

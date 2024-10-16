# frozen_string_literal: true

RSpec.describe CrosswalkIssue, type: :model do
  describe 'when building partial matches' do
    def ignore_issue(issue)
      # copied from controller
      IgnoredCrosswalkIssue.create(
        cross: issue.ipeds_hd.present? ? issue.ipeds_hd.cross : issue.crosswalk.cross,
        ope: issue.ipeds_hd.present? ? issue.ipeds_hd.ope : issue.crosswalk.ope,
        facility_code: issue.weam.facility_code
      )
    end

    it 'has a valid factory' do
      crosswalk_issue = build(:crosswalk_issue, :with_weam_match)
      expect(crosswalk_issue).to be_valid
    end

    it 'errors if no parent is present' do
      crosswalk_issue = build(:crosswalk_issue, :partial_match_type)
      expect(crosswalk_issue).not_to be_valid
    end

    def ignore_and_validate_delete_of_only_partial_match_issue
      issue = described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).first
      ignore_issue(issue)
      issue.delete

      # issue is gone:
      expect(described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count).to eq 0
    end

    it 'matches NCD weams and ipeds_hds by cross (IPEDS)' do
      create :weam, :ncd, :approved_poo_and_law_code, :crosswalk_issue_matchable_by_cross
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)
    end

    it 'matches IHL weams and ipeds_hds by cross (IPEDS)' do
      create :weam, :approved_poo_and_law_code, :higher_learning, :crosswalk_issue_matchable_by_cross
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)
    end

    it 'matches NCD weams and ipeds_hds on ope' do
      create :weam, :approved_poo_and_law_code, :ncd, :crosswalk_issue_matchable_by_ope
      create :ipeds_hd, :crosswalk_issue_matchable_by_ope

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)
    end

    it 'matches IHL weams and ipeds_hds on ope' do
      create :weam, :approved_poo_and_law_code, :higher_learning, :crosswalk_issue_matchable_by_ope
      create :ipeds_hd, :crosswalk_issue_matchable_by_ope

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)
    end

    it 'matches NCD weams and crosswalks on facility_code' do
      create :weam, :ncd, :approved_poo_and_law_code, :crosswalk_issue_matchable_by_facility_code
      create :crosswalk, :crosswalk_issue_matchable_by_facility_code

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)
    end

    it 'matches IHL weams and crosswalks on facility_code' do
      create :weam, :approved_poo_and_law_code, :higher_learning, :crosswalk_issue_matchable_by_facility_code
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

    it 'excludes weams without approved poos_status' do
      create :weam, :withdrawn_poo, :higher_learning, :crosswalk_issue_matchable_by_cross
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross

      described_class.rebuild
      expect(described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count).to eq(0)
    end

    it 'excludes weams with not-approved applicable_law_code' do
      create :weam, :approved_poo_and_non_approved_law_code, :higher_learning, :crosswalk_issue_matchable_by_cross
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross

      described_class.rebuild
      expect(described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count).to eq(0)
    end

    it 'excludes weams with chapter 31 only applicable_law_code' do
      create :weam, :approved_poo_and_law_code_title_31, :higher_learning, :crosswalk_issue_matchable_by_cross
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross

      described_class.rebuild
      expect(described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count).to eq(0)
    end

    it 'excludes weams with blank applicable_law_code' do
      create :weam, :higher_learning, :crosswalk_issue_matchable_by_cross, poo_status: 'APRVD', applicable_law_code: ''
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross

      described_class.rebuild
      expect(described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count).to eq(0)
    end

    it 'excludes weams with null applicable_law_code' do
      create :weam, :higher_learning, :crosswalk_issue_matchable_by_cross, poo_status: 'APRVD'
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross

      described_class.rebuild
      expect(described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count).to eq(0)
    end

    it 'excludes ignored crosswalk issues with ipeds_hd IPEDS match' do
      create :weam, :ncd, :approved_poo_and_law_code, :crosswalk_issue_matchable_by_cross,
             :crosswalk_issue_matchable_by_facility_code
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)

      ignore_and_validate_delete_of_only_partial_match_issue

      expect { described_class.rebuild }
        .not_to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }
    end

    it 'excludes ignored crosswalk issues with ipeds_hd OPE match' do
      create :weam, :ncd, :approved_poo_and_law_code, :crosswalk_issue_matchable_by_ope,
             :crosswalk_issue_matchable_by_facility_code
      create :ipeds_hd, :crosswalk_issue_matchable_by_ope

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)

      ignore_and_validate_delete_of_only_partial_match_issue

      expect { described_class.rebuild }
        .not_to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }
    end

    it 'excludes ignored crosswalk issues with crosswalk IPEDS match' do
      create :weam, :ncd, :approved_poo_and_law_code, :crosswalk_issue_matchable_by_facility_code,
             :crosswalk_issue_matchable_by_facility_code
      create :crosswalk, :crosswalk_issue_matchable_by_facility_code, :crosswalk_issue_matchable_by_cross

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)

      ignore_and_validate_delete_of_only_partial_match_issue

      expect { described_class.rebuild }
        .not_to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }
    end

    it 'excludes ignored crosswalk issues with crosswalk OPE match' do
      create :weam, :ncd, :approved_poo_and_law_code, :crosswalk_issue_matchable_by_facility_code
      create :crosswalk, :crosswalk_issue_matchable_by_facility_code, :crosswalk_issue_matchable_by_ope

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)

      ignore_and_validate_delete_of_only_partial_match_issue

      expect { described_class.rebuild }
        .not_to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }
    end

    it 'does not exclude partial match ignored crosswalk issues on following rebuild' do
      create :weam, :ncd, :approved_poo_and_law_code, :crosswalk_issue_matchable_by_cross,
             :crosswalk_issue_matchable_by_facility_code
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross

      described_class.rebuild

      ignore_and_validate_delete_of_only_partial_match_issue

      # Record now has an `ope` set.  Since ope has changed, we expect an issue to be generated
      create :ipeds_hd, :crosswalk_issue_matchable_by_cross, ope: '0000000A'

      expect { described_class.rebuild }
        .to change { described_class.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).count }.from(0).to(1)
    end
  end

  describe '#by_domestic_crosswalks via crosswalk' do
    it 'includes crosswalks that have facility codes with the last 2 characters < 51' do
      create(:crosswalk, :domestic_with_crosswalk_issue)
      create(:crosswalk, :foreign_with_crosswalk_issue)

      expect(described_class.by_domestic_crosswalks.count).to eq(1)
    end
  end

  describe '#by_domestic_crosswalks via weams' do
    it 'includes crosswalks that have facility codes with the last 2 characters < 51' do
      create(:weam, :domestic_with_crosswalk_issue)
      create(:weam, :foreign_with_crosswalk_issue)

      expect(described_class.by_domestic_weams.count).to eq(1)
    end
  end

  describe '#by_domestic_crosswalks via ipeds_hds' do
    it 'includes crosswalks that have facility codes with the last 2 characters < 51' do
      create(:weam, :domestic_with_ipeds_hd_crosswalk_issue)
      create(:weam, :foreign_with_ipeds_hd_crosswalk_issue)

      expect(described_class.by_domestic_iped_hds.count).to eq(1)
    end
  end

  describe '#domestic_partial_matches' do
    it 'includes crosswalks that have facility codes with the last 2 characters < 51' do
      create(:crosswalk, :domestic_with_crosswalk_issue)
      create(:crosswalk, :foreign_with_crosswalk_issue)
      create(:weam, :domestic_with_crosswalk_issue)
      create(:weam, :foreign_with_crosswalk_issue)
      create(:weam, :domestic_with_ipeds_hd_crosswalk_issue)
      create(:weam, :foreign_with_ipeds_hd_crosswalk_issue)

      expect(described_class.domestic_partial_matches.count).to eq(3)
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

  describe '#resolved?' do
    context 'when cross and ope fields match across ipeds_hd, crosswalk, and weams' do
      it 'is resolved' do
        issue = create :crosswalk_issue, :with_weam_match, :with_crosswalk_match, :with_ipeds_hd_match
        expect(issue.resolved?).to eq(true)
      end
    end

    context 'when cross and ope fields do not match across ipeds_hd, crosswalk, and weams' do
      it 'is not resolved' do
        issue = create :crosswalk_issue, :with_weam_match
        expect(issue.resolved?).to eq(false)
      end
    end
  end

  describe '#export_and_pluck_partials' do
    it 'responds to #export_and_pluck_partials' do
      expect(described_class).to respond_to(:export_and_pluck_partials)
    end

    it 'returns an array of partials' do
      create(:crosswalk_issue, :with_weam_match, :with_ipeds_hd_match, :partial_match_type)

      # Array of Arrays
      expect(described_class.export_and_pluck_partials).to be_an(Array)
      expect(described_class.export_and_pluck_partials[0]).to be_an(Array)
    end
  end
end

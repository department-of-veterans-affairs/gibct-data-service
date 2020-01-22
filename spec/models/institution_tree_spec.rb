# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionTree, type: :model do
  let(:version) { Version.current_preview }

  describe 'institution tree' do
    before do
      create :version, :production
      create(:institution, facility_code: '100', campus_type: 'Y', version_id: Version.current_production.id)
      create(:institution, facility_code: '101', parent_facility_code_id: '100', campus_type: 'N', version_id: Version.current_production.id)
      create(:institution, facility_code: '102', parent_facility_code_id: '100', campus_type: 'N', version_id:  Version.current_production.id)
      create(:institution, facility_code: '103', parent_facility_code_id: '100', campus_type: 'N', version_id:  Version.current_production.id)
      create(:institution, facility_code: '104', parent_facility_code_id: '102', campus_type: 'E', version_id:  Version.current_production.id)
      create(:institution, facility_code: '105', parent_facility_code_id: '103', campus_type: 'E', version_id:  Version.current_production.id)
      create(:institution, facility_code: '106', parent_facility_code_id: '103', campus_type: 'E', version_id:  Version.current_production.id)
      create(:institution, facility_code: '107', parent_facility_code_id: '103', campus_type: 'E', version_id:  Version.current_production.id)
      create(:institution, facility_code: '108', parent_facility_code_id: '100', campus_type: 'E', version_id:  Version.current_production.id)
      create(:institution, facility_code: '109', version_id: Version.current_production.id)
      create :version, :production
      create(:institution, facility_code: '110', parent_facility_code_id: '100', campus_type: 'E', version_id: Version.current_production.id)
    end

    context 'when built' do
      def check_branches_and_extensions(tree)
        expect(tree['main']['branches'].count).to eq(3)
        expect(tree['main']['extensions'].count).to eq(1)
        expect(tree['main']['branches'][0]['extensions'].count).to eq(0)
        expect(tree['main']['branches'][1]['extensions'].count).to eq(1)
        expect(tree['main']['branches'][2]['extensions'].count).to eq(3)
      end

      it 'generates correctly for main facility' do
        tree = described_class.build(Institution.find_by(facility_code: '100'))
        check_branches_and_extensions(tree)
      end

      it 'generates correctly for branch facility' do
        tree = described_class.build(Institution.find_by(facility_code: '101'))
        check_branches_and_extensions(tree)
      end

      it 'generates correctly for extension facility' do
        tree = described_class.build(Institution.find_by(facility_code: '107'))
        check_branches_and_extensions(tree)
      end

      it 'generates correctly for facility without campus_type value' do
        tree = described_class.build(Institution.find_by(facility_code: '109'))
        expect(tree['main']['branches'].count).to eq(0)
        expect(tree['main']['extensions'].count).to eq(0)
      end
    end
  end
end

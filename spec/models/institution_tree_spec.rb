# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionTree, type: :model do
  let(:version) { create(:version, :production) }

  describe 'intitution tree' do
    before(:each) do
      create(:institution, facility_code: '100', campus_type: 'Y')
      create(:institution, facility_code: '101', parent_facility_code_id: '100', campus_type: 'N')
      create(:institution, facility_code: '102', parent_facility_code_id: '100', campus_type: 'N')
      create(:institution, facility_code: '103', parent_facility_code_id: '100', campus_type: 'N')
      create(:institution, facility_code: '104', parent_facility_code_id: '102', campus_type: 'E')
      create(:institution, facility_code: '105', parent_facility_code_id: '103', campus_type: 'E')
      create(:institution, facility_code: '106', parent_facility_code_id: '103', campus_type: 'E')
      create(:institution, facility_code: '107', parent_facility_code_id: '103', campus_type: 'E')
      create(:institution, facility_code: '108', parent_facility_code_id: '100', campus_type: 'E')
      create(:institution, facility_code: '109')
    end

    context 'when built' do
      it 'generates correctly for main facility' do
        tree = InstitutionTree.build(Institution.find_by(facility_code: '100'))
        expect(tree['main']['branches'].count).to eq(3)
        expect(tree['main']['extensions'].count).to eq(1)
        expect(tree['main']['branches'][0]['extensions'].count).to eq(0)
        expect(tree['main']['branches'][1]['extensions'].count).to eq(1)
        expect(tree['main']['branches'][2]['extensions'].count).to eq(3)
      end

      it 'generates correctly for branch facility' do
        tree = InstitutionTree.build(Institution.find_by(facility_code: '101'))
        expect(tree['main']['branches'].count).to eq(3)
        expect(tree['main']['extensions'].count).to eq(1)
        expect(tree['main']['branches'][0]['extensions'].count).to eq(0)
        expect(tree['main']['branches'][1]['extensions'].count).to eq(1)
        expect(tree['main']['branches'][2]['extensions'].count).to eq(3)
      end

      it 'generates correctly for extension facility' do
        tree = InstitutionTree.build(Institution.find_by(facility_code: '107'))
        expect(tree['main']['branches'].count).to eq(3)
        expect(tree['main']['extensions'].count).to eq(1)
        expect(tree['main']['branches'][0]['extensions'].count).to eq(0)
        expect(tree['main']['branches'][1]['extensions'].count).to eq(1)
        expect(tree['main']['branches'][2]['extensions'].count).to eq(3)
      end

      it 'generates correctly for facility without campus_type value' do
        tree = InstitutionTree.build(Institution.find_by(facility_code: '109'))
        expect(tree['main']['branches'].count).to eq(0)
        expect(tree['main']['extensions'].count).to eq(0)
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
require_relative './shared_setup'

RSpec.describe InstitutionBuilder, type: :model do
  include_context('with setup')

  describe 'when processing section 1015s' do
    let(:production_version) { Version.current_production }
    let(:institution1) { create(:institution, :section1015a, version_id: production_version.id) }
    let(:institution2) { create(:institution, :section1015b, version_id: production_version.id) }

    before do
      create(:weam, :institution_builder, :approved_institution)
      create(:weam, :institution_builder2, :approved_institution)
      create(:section1015)
      create(:section1015, :celo_n)

      [institution1, institution2].each do |inst|
        inst.version = production_version
        inst.save
      end
    end

    it "removes from approved institutions with celo other than 'n' " do
      expect(Institution.approved_institutions(Version.last.id).count).to eq(2)
      described_class.run(user)
      expect(Institution.approved_institutions(Version.last.id).count).to eq(1)
    end
  end
end

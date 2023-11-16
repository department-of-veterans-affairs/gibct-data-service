# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionBuilder, type: :model do
  let(:user) { User.first }
  let(:institutions) { Institution.where(version: Version.current_production) }
  let(:factory_class) { InstitutionBuilder::Factory }

  before do
    create :user, email: 'fred@va.gov', password: 'fuggedabodit'
    allow(VetsApi::Service).to receive(:feature_enabled?).and_return(false)
    create(:version, :production)
  end

  describe 'when processing section 1015s' do
    let(:production_version) { Version.current_production }
    let(:institution1) { create(:institution, :section1015a) }
    let(:institution2) { create(:institution, :section1015b) }

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

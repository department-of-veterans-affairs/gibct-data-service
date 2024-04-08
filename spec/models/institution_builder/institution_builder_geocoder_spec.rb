# frozen_string_literal: true

require 'rails_helper'
require_relative './shared_setup'

RSpec.describe InstitutionBuilder, type: :model do
  include_context('with setup')

  describe '#run - with geocoding and updating geocoding from production' do
    let(:production_version) { Version.current_production }
    let(:institution) { create(:institution, :physical_address, version_id: production_version.id) }

    before do
      weam = create(:weam, :physical_address, :approved_institution)
      weam.facility_code = '12345'
      weam.save(validate: false)
      institution.version = production_version
      institution.facility_code = '12345'
    end

    it 'copies long and lat from production as part of generating' do
      institution.longitude = 39.14
      institution.latitude = -75.09
      institution.save
      described_class.run(user)
      institution2 = Institution.last

      expect(institution2.version_id).to eq(Version.current_production.id)
      expect(institution2.longitude).to eq(39.14)
      expect(institution2.latitude).to eq(-75.09)
    end

    it 'does not copy long and lat from production as part of generating preview if address changes' do
      institution.longitude = 39.14
      institution.latitude = -75.09
      institution.physical_zip = '22222'
      institution.save
      described_class.run(user)
      institution2 = Institution.last
      expect(institution2.version_id).to eq(Version.current_production.id)
      expect(institution2.longitude).not_to eq(39.14)
      expect(institution2.latitude).not_to eq(-75.09)
    end
  end
end

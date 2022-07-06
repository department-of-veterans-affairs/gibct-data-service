# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchGeocoder, type: :model do
  let(:version) { create(:version, :preview) }

  describe '#process_geocoder_address' do
    it 'does not process without version' do
      institution = create :institution, :regular_address
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(nil)
      geo_search_results.process_geocoder_address
      expect(geo_search_results.results).to eq([])
      expect(geo_search_results.results).to eq([])
      expect(institution.latitude).to eq(nil)
      expect(institution.longitude).to eq(nil)
    end

    it 'updates coordinates using address field' do
      institution = create :institution, :regular_address
      institution.update(address_2: nil, address_3: nil)
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(geo_search_results.results.count).to eq(Institution.count)
      expect(Institution.last.latitude.round(2)).to eq(42.6840271.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.82587727551194.round(2))
    end

    it 'updates coordinates using address_1 field' do
      institution = create :institution, :regular_address
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(geo_search_results.results.count).to eq(Institution.count)
      expect(Institution.last.latitude.round(2)).to eq(42.6840271.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.82587727551194.round(2))
    end

    it 'updates coordinates using address_2 field' do
      institution = create :institution, :regular_address_2
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(geo_search_results.results.count).to eq(Institution.count)
      expect(Institution.last.latitude.round(2)).to eq(42.6840271.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.82587727551194.round(2))
    end

    it 'updates coordinates bad address fields' do
      institution = create :institution, :bad_address
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(geo_search_results.results.count).to eq(Institution.count)
      expect(Institution.last.latitude.round(2)).to eq(42.6840271.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.82587727551194.round(2))
    end

    it 'updates coordinates bad address fields, can not find address' do
      institution = create :institution, :bad_address
      institution.update(version: version, version_id: version.id, address_1: 'sunshine highway')
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(geo_search_results.results.count).to eq(Institution.count)
      expect(Institution.last.latitude.round(2)).to eq(42.6511674.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.754968.round(2))
      expect(Institution.last.bad_address).to eq(true)
    end

    it 'updates coordinates bad address fields by name' do
      institution = create :institution, :bad_address_with_name
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(geo_search_results.results.count).to eq(Institution.count)
      expect(Institution.last.latitude.round(2)).to eq(42.6840271.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.82587727551194.round(2))
    end

    it 'coordinates bad address fields by name with numbering' do
      # fixed flakey test
      institution = create :institution, :bad_address_with_name_numbered
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(geo_search_results.results.count).to eq(Institution.count)
      expect(Institution.last.latitude.round(1)).to eq(33.7976469.round(1))
      expect(Institution.last.longitude.round(1)).to eq(-84.4159008.round(1))
    end

    it 'updates coordinates bad address fields, country' do
      institution = create :institution, :regular_address_country
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_country
      expect(geo_search_results.results.count).to eq(Institution.count)
      expect(Institution.last.latitude.round(2)).to eq(40.6150446.round(2))
      expect(Institution.last.longitude.round(2)).to eq(15.0495566.round(2))
    end

    it 'updates coordinates bad address fields, country with state' do
      institution = create :institution, :regular_address_country
      institution.update(version: version, version_id: version.id, state: 'NY')
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_country
      expect(geo_search_results.results.count).to eq(Institution.count)
      expect(Institution.last.latitude.round(2)).to eq(42.6384261.round(2))
      expect(Institution.last.longitude.round(2)).to eq(12.674297.round(2))
    end
  end
end

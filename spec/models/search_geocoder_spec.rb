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

    it 'decrements the results after a successful geocode' do
      institution = create :institution, :regular_address
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(version)
      expect(geo_search_results.results.count).to eq(Institution.count)
      geo_search_results.process_geocoder_address
      expect(geo_search_results.results.count).to eq(0)
    end

    it 'updates coordinates using address field' do
      institution = create :institution, :regular_address
      institution.update(address_2: nil, address_3: nil)
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(Institution.last.latitude.round(2)).to eq(42.6840271.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.82587727551194.round(2))
    end

    it 'updates coordinates using address_1 field' do
      institution = create :institution, :regular_address
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(Institution.last.latitude.round(2)).to eq(42.6840271.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.82587727551194.round(2))
    end

    it 'updates coordinates using address_2 field' do
      institution = create :institution, :regular_address_2
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(Institution.last.latitude.round(2)).to eq(42.6840271.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.82587727551194.round(2))
    end

    it 'updates coordinates bad address fields' do
      institution = create :institution, :bad_address
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(Institution.last.latitude.round(2)).to eq(42.6840271.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.82587727551194.round(2))
    end

    it 'updates coordinates bad address fields, can not find address' do
      institution = create :institution, :bad_address
      institution.update(version: version, version_id: version.id, address_1: 'sunshine highway')
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(Institution.last.latitude.round(2)).to eq(42.6511674.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.754968.round(2))
      expect(Institution.last.bad_address).to eq(true)
    end

    it 'updates coordinates bad address fields by name' do
      institution = create :institution, :bad_address_with_name
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(Institution.last.latitude.round(2)).to eq(42.6840271.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.82587727551194.round(2))
    end

    it 'coordinates bad address fields by name with numbering' do
      # fixed flakey test
      institution = create :institution, :bad_address_with_name_numbered
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(Institution.last.latitude.round(1)).to eq(33.7976469.round(1))
      expect(Institution.last.longitude.round(1)).to eq(-84.4159008.round(1))
    end

    it 'updates coordinates bad address fields, country' do
      institution = create :institution, :regular_address_country
      institution.update(version: version, version_id: version.id)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_country
      expect(Institution.last.latitude.round(2)).to eq(40.6150446.round(2))
      expect(Institution.last.longitude.round(2)).to eq(15.0495566.round(2))
    end

    it 'updates coordinates bad address fields, country with state' do
      institution = create :institution, :regular_address_country
      institution.update(version: version, version_id: version.id, state: 'NY')
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_country
      expect(Institution.last.latitude.round(2)).to eq(42.6384261.round(2))
      expect(Institution.last.longitude.round(2)).to eq(12.674297.round(2))
    end

    it 'adds records to the progress table as it runs' do
      institution = create :institution, :regular_address
      institution.update(version: version, version_id: version.id)
      initial_progress_count = PreviewGenerationStatusInformation.count
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(PreviewGenerationStatusInformation.count).to be > initial_progress_count
    end

    it 'sets the ungeocodable flag to true if it could not find the coordinates' do
      allow(Rails.logger).to receive(:info)
      institution = create :institution, :regular_address
      institution.update(version: version, version_id: version.id)
      geo_search = described_class.new(version)
      geo_search.update_mismatch(institution, nil)
      expect(institution.ungeocodable).to be true
      expect(Rails.logger).to have_received(:info).with(/No coordinates found/).at_least(:once)
    end

    describe 'exception handling' do
      [
        Timeout::Error, SocketError, Geocoder::OverQueryLimitError, Geocoder::RequestDenied,
        Geocoder::InvalidRequest, Geocoder::InvalidApiKey, Geocoder::ServiceUnavailable,
        Geocoder::ResponseParseError
      ].each do |geocoding_exception|
        it "handles #{geocoding_exception} exception when calling the geocoder api", strategy: :truncation do
          run_exception_test(geocoding_exception)
        end
      end

      def run_exception_test(geocoding_exception)
        allow(Rails.logger).to receive(:info)
        create_institution
        geo_search = described_class.new(version)
        results = geo_search.send :geocode_addy, 'exception_test', geocoding_exception, 0
        expect(results[0]).to be_nil
        expect(results[1]).to be true

        expect(Rails.logger).to have_received(:info).with(/Geocode/).at_least(:once)
      end

      def create_institution
        institution = create :institution, :regular_address
        institution.update(version: version, version_id: version.id)
      end
    end
  end

  describe '#initialize' do
    it 'only includes current preview institutions with null long and lat' do
      non_geocoded_institution = create :institution, :regular_address
      non_geocoded_institution.update(version: version, version_id: version.id)
      geocoded_institution = create :institution, :location
      geocoded_institution.update(version: version, version_id: version.id)

      geocoder = described_class.new(version)
      expect(geocoder.results.first.longitude).to be_nil
      expect(geocoder.results.first.latitude).to be_nil
      expect(geocoder.results.ids).not_to include(geocoded_institution.id)
    end

    def create_institution(trait, version)
      institution = create :institution, trait
      institution.update(version: version, version_id: version.id)
      institution
    end

    it 'by_address collection only includes country USA or nil' do
      institution1 = create_institution(:physical_address, version)
      institution2 = create_institution(:regular_address_country_nil, version)
      institution3 = create_institution(:regular_address_country, version)

      geocoder = described_class.new(version)
      expect(geocoder.by_address.ids).to include(institution1.id)
      expect(geocoder.by_address.ids).to include(institution2.id)
      expect(geocoder.by_address.ids).not_to include(institution3.id)
    end

    it 'stops trying to geocode after a successful geocode match' do
      institution = create :institution, :mixed_addresses
      institution.update(version: version, version_id: version.id)
      geocoder = described_class.new(version)
      geocoder.process_geocoder_address

      # addresses get combined into address[0], address[1] and address[2] behave as expected
      expect(Institution.first.latitude.round(2)).to eq(38.9890174.round(2))
      expect(Institution.first.longitude.round(2)).to eq(-77.149411.round(2))
    end

    it 'geocodes foreign address in bad_address logic if unable to geocode by address lines' do
      institution = create :institution, :foreign_bad_address
      institution.update(version: version, version_id: version.id)
      geocoder = described_class.new(version)
      geocoder.process_geocoder_address
      expect(Institution.first.longitude).not_to be_nil
      expect(Institution.first.latitude).not_to be_nil
    end

    it 'does not set bad_address flag for foreign institutions' do
      institution = create :institution, :foreign_bad_address
      institution.update(version: version, version_id: version.id)
      geocoder = described_class.new(version)
      geocoder.process_geocoder_address
      expect(Institution.first.bad_address).not_to eq(true)
    end
  end
end

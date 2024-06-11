# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchGeocoder, type: :model do
  let(:version) { create(:version, :preview) }

  before do
    # rubocop:disable Style/ColonMethodCall
    Geocoder::configure(:lookup => :test)
    Geocoder::Lookup::Test.add_stub(
      '1400 Washington Ave 1400 Washington Ave #123 Unit abc, ALBANY, NY, 12222, USA',
      [{ 'coordinates' => [42.6840271, -73.82587727551194] }]
    )
    Geocoder::Lookup::Test.add_stub(
      '1400 Washington Ave, ALBANY, NY, 12222, USA',
      [{ 'coordinates' => [42.6840271, -73.82587727551194] }]
    )

    Geocoder::Lookup::Test.add_stub(
      '1400 Washington bdvd 122123d 1400 Washington Ave Unit abc, ALBANY, NY, 12222, USA',
      [{ 'coordinates' => [42.6840271, -73.82587727551194] }]
    )
    Geocoder::Lookup::Test.add_stub(
      '1400 Washington bdvd 122123d, ALBANY, NY, 12222, USA',
      [{ 'coordinates' => [42.6840271, -73.82587727551194] }]
    )
    Geocoder::Lookup::Test.add_stub(
      '1400 Washington Ave #123, ALBANY, NY, 12222, USA',
      [{ 'coordinates' => [42.6840271, -73.82587727551194] }]
    )
    Geocoder::Lookup::Test.add_stub(
      '1400 Washington bdvd 122123d, ATLANTA, GA, , USA',
      [{ 'coordinates' => [33.7976469, -84.4159008] }]
    )
    Geocoder::Lookup::Test.add_stub(
      'CASH OFFICE FIN SVCS UNIT 1 MARKET SQUARE, HESLINGTON YORK, , , UNITED KINGDOM',
      [{ 'coordinates' => nil }]
    )
    Geocoder::Lookup::Test.add_stub(
      'CASH OFFICE FIN SVCS, HESLINGTON YORK, , , UNITED KINGDOM',
      [{ 'coordinates' => nil }]
    )
    Geocoder::Lookup::Test.add_stub(
      'UNIT 1 MARKET SQUARE, HESLINGTON YORK, , , UNITED KINGDOM',
      [{ 'coordinates' => nil }]
    )
    Geocoder::Lookup::Test.add_stub(
      'HESLINGTON YORK, , ',
      [{ 'coordinates' => nil }]
    )
    Geocoder::Lookup::Test.add_stub(
      'institution 1000',
      [{ 'coordinates' => nil }]
    )
    Geocoder::Lookup::Test.add_stub(
      '1400 Washington Ave #123 1400 Washington Ave xwexewxwexwx Unit abc xwexwxwex, ALBANY, NY, 12222, USA',
      [{ 'coordinates' => nil }]
    )
    Geocoder::Lookup::Test.add_stub(
      '1400 Washington bdvd 122123d 1400 Washington Ave xwexewxwexwx Unit abc xwexwxwex, ALBANY, NY, 12222, USA',
      [{ 'coordinates' => nil }]
    )
    Geocoder::Lookup::Test.add_stub(
      '1400 Washington bdvd 122123d 1400 Washington Ave xwexewxwexwx Unit abc xwexwxwex, ATLANTA, GA, , USA',
      [{ 'coordinates' => nil }]
    )
    Geocoder::Lookup::Test.add_stub(
      'sunshine highway 1400 Washington Ave xwexewxwexwx Unit abc xwexwxwex, ALBANY, NY, 12222, USA',
      [{ 'coordinates' => nil }]
    )
    Geocoder::Lookup::Test.add_stub(
      'sunshine highway, ALBANY, NY, 12222, USA',
      [{ 'coordinates' => nil }]
    )
    Geocoder::Lookup::Test.add_stub(
      'ALBANY, NY, 12222',
      [{ 'coordinates' => [42.6511674, -73.754968] }]
    )
    Geocoder::Lookup::Test.add_stub(
      'sunshine highway 1400 Washington Ave NY 12222',
      [{ 'coordinates' => [42.6511674, -73.754968] }]
    )
    Geocoder::Lookup::Test.add_stub(
      '1400 Washington Ave xwexewxwexwx, ALBANY, NY, 12222, USA',
      [{ 'coordinates' => nil }]
    )
    Geocoder::Lookup::Test.add_stub(
      'IT',
      [{ 'coordinates' => [42.6384261, 12.674297] }]
    )
    Geocoder::Lookup::Test.add_stub(
      '8500 River Rd 7100 Whittier Blvd, Bethesda, MD, 20817, USA',
      [{ 'coordinates' => [38.981725, -77.1297884] }]
    )
    Geocoder::Lookup::Test.add_stub(
      'Via Giovanni Paolo I Via Giovanni Paolo I#123 Unit abc, SAlERNO, IT',
      [{ 'coordinates' => [40.6150446, 15.0495566] }]
    )
    # rubocop:enable Style/ColonMethodCall
  end

  describe '#process_geocoder_address' do
    it 'does not process without version' do
      institution = build_and_create_institution(:regular_address)
      geo_search_results = described_class.new(nil)
      geo_search_results.process_geocoder_address
      expect(geo_search_results.results).to eq([])
      expect(geo_search_results.results).to eq([])
      expect(institution.latitude).to eq(nil)
      expect(institution.longitude).to eq(nil)
    end

    it 'decrements the results after a successful geocode' do
      build_and_create_institution(:regular_address)
      geo_search_results = described_class.new(version)
      expect(geo_search_results.results.count).to eq(Institution.count)
      geo_search_results.process_geocoder_address
      expect(geo_search_results.results.count).to eq(0)
    end

    it 'updates coordinates using address field' do
      institution = build_and_create_institution(:regular_address)
      institution.update(address_2: nil, address_3: nil)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(Institution.last.latitude.round(2)).to eq(42.6840271.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.82587727551194.round(2))
    end

    it 'updates coordinates using address_1 field' do
      build_and_create_institution(:regular_address)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(Institution.last.latitude.round(2)).to eq(42.6840271.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.82587727551194.round(2))
    end

    it 'updates coordinates using address_2 field' do
      build_and_create_institution(:regular_address_2)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(Institution.last.latitude.round(2)).to eq(42.6840271.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.82587727551194.round(2))
    end

    it 'updates coordinates bad address fields' do
      build_and_create_institution(:bad_address)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(Institution.last.latitude.round(2)).to eq(42.6840271.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.82587727551194.round(2))
    end

    it 'updates coordinates bad address fields, can not find address' do
      institution = build_and_create_institution(:bad_address)
      institution.update(address_1: 'sunshine highway')
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(Institution.last.latitude.round(2)).to eq(42.6511674.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.754968.round(2))
      expect(Institution.last.bad_address).to eq(true)
    end

    it 'updates coordinates bad address fields by name' do
      build_and_create_institution(:bad_address_with_name)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(Institution.last.latitude.round(2)).to eq(42.6840271.round(2))
      expect(Institution.last.longitude.round(2)).to eq(-73.82587727551194.round(2))
    end

    it 'coordinates bad address fields by name with numbering' do
      # fixed flakey test
      build_and_create_institution(:bad_address_with_name_numbered)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_address
      expect(Institution.last.latitude.round(1)).to eq(33.7976469.round(1))
      expect(Institution.last.longitude.round(1)).to eq(-84.4159008.round(1))
    end

    it 'updates coordinates bad address fields, country' do
      build_and_create_institution(:regular_address_country)
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_country
      expect(Institution.last.latitude.round(2)).to eq(40.6150446.round(2))
      expect(Institution.last.longitude.round(2)).to eq(15.0495566.round(2))
    end

    it 'updates coordinates bad address fields, country with state' do
      institution = build_and_create_institution(:regular_address_country)
      institution.update(state: 'NY')
      geo_search_results = described_class.new(version)
      geo_search_results.process_geocoder_country
      expect(Institution.last.latitude.round(2)).to eq(42.6384261.round(2))
      expect(Institution.last.longitude.round(2)).to eq(12.674297.round(2))
    end

    it 'adds records to the progress table as it runs' do
      build_and_create_institution :regular_address
      initial_progress_count = PreviewGenerationStatusInformation.count
      geo_search_results = described_class.new(version)

      perform_enqueued_jobs do
        geo_search_results.process_geocoder_address
      end

      expect(PreviewGenerationStatusInformation.count).to be > initial_progress_count
    end

    it 'sets the ungeocodable flag to true if it could not find the coordinates' do
      allow(Rails.logger).to receive(:info)
      institution = build_and_create_institution(:regular_address)
      geo_search = described_class.new(version)
      geo_search.update_mismatch(institution, nil)
      expect(institution.ungeocodable).to be true
      expect(Rails.logger).to have_received(:info).with(/No coordinates found/).at_least(:once)
    end

    describe 'exception handling' do
      [
        Timeout::Error, SocketError, Geocoder::OverQueryLimitError, Geocoder::RequestDenied,
        Geocoder::InvalidRequest, Geocoder::InvalidApiKey, Geocoder::ServiceUnavailable,
        Geocoder::ResponseParseError, Geocoder::NetworkError
      ].each do |geocoding_exception|
        it "handles #{geocoding_exception} exception when calling the geocoder api", strategy: :truncation do
          run_exception_test(geocoding_exception)
        end
      end

      def run_exception_test(geocoding_exception)
        allow(Rails.logger).to receive(:info)
        build_and_create_institution(:regular_address)
        geo_search = described_class.new(version)
        results = geo_search.send :geocode_addy, 'exception_test', geocoding_exception, 0
        expect(results[0]).to be_nil
        expect(results[1]).to be true

        expect(Rails.logger).to have_received(:info).with(/Geocode/).at_least(:once)
      end
    end
  end

  describe '#initialize' do
    it 'only includes current preview institutions with null long and lat' do
      non_geocoded_institution = build_and_create_institution :regular_address
      geocoded_institution = build_and_create_institution :location

      geocoder = described_class.new(version)
      expect(geocoder.results.first.longitude).to be_nil
      expect(geocoder.results.first.latitude).to be_nil
      expect(geocoder.results.ids).not_to include(geocoded_institution.id)
      expect(geocoder.results.ids).to include(non_geocoded_institution.id)
    end

    it 'by_address collection only includes country USA or nil' do
      institution1 = build_and_create_institution(:physical_address)
      institution2 = build_and_create_institution(:regular_address_country_nil)
      institution3 = build_and_create_institution(:regular_address_country)

      geocoder = described_class.new(version)
      expect(geocoder.by_address.ids).to include(institution1.id)
      expect(geocoder.by_address.ids).to include(institution2.id)
      expect(geocoder.by_address.ids).not_to include(institution3.id)
    end

    it 'stops trying to geocode after a successful geocode match' do
      build_and_create_institution :mixed_addresses
      geocoder = described_class.new(version)
      geocoder.process_geocoder_address

      # addresses get combined into address[0], address[1] and address[2] behave as expected
      expect(Institution.first.latitude.round(2)).to eq(38.98)
      expect(Institution.first.longitude.round(2)).to eq(-77.13)
    end

    it 'geocodes foreign address in bad_address logic if unable to geocode by address lines' do
      build_and_create_institution :foreign_bad_address
      geocoder = described_class.new(version)
      geocoder.process_geocoder_address
      expect(Institution.first.longitude).not_to be_nil
      expect(Institution.first.latitude).not_to be_nil
    end

    it 'does not set bad_address flag for foreign institutions' do
      build_and_create_institution :foreign_bad_address
      geocoder = described_class.new(version)
      geocoder.process_geocoder_address
      expect(Institution.first.bad_address).not_to eq(true)
    end
  end

  # Rails 7 is enforcing that version must be present when instantiating an institution
  def build_and_create_institution(trait)
    institution = build :institution, trait
    institution.version = version
    institution.version_id = version.id
    institution.save
    update_institution_name(institution)
    institution
  end

  def update_institution_name(institution)
    return institution unless institution.institution.start_with?('institution')

    institution.institution = 'institution 1000'
    institution.save
  end
end

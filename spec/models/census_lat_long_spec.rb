# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CensusLatLong, type: :model do
  describe 'export' do
    it 'returns binary_data' do
      create :version
      create(:institution, :physical_address, version: Version.latest)

      binary_data = described_class.export
      expect(binary_data).to be_present
    end
  end

  describe 'add_institution_addresses' do
    before do
      create :version
    end

    it 'includes an institution missing lat long' do
      create(:institution, :physical_address, version: Version.latest)
      create(:institution, :lat_long, version: Version.latest)

      addresses = []
      described_class.add_institution_addresses(addresses, [])
      expect(addresses.count).to eq(0)
    end

    it 'does not include an institution missing lat long whose facility code also qualifies from weams' do
      weam = create(:weam)
      create(:institution, facility_code: weam.facility_code, version: Version.latest)

      addresses = []
      described_class.add_institution_addresses(addresses, [weam.facility_code])
      expect(addresses.count).to eq(0)
    end
  end

  describe 'add_weams_physical_addresses' do
    it 'includes a weam row with physical address values' do
      weam = create(:weam, :no_physical_address)
      weam1 = create(:weam, :physical_address)

      addresses = []
      described_class.add_weams_physical_addresses(addresses, [weam1, weam])
      expect(addresses.count).to eq(1)
    end
  end

  describe 'add_weams_mailing_addresses' do
    it 'includes a weam row without physical address values' do
      weam = create(:weam, :mailing_address)
      weam1 = create(:weam, :no_mailing_address)

      addresses = []
      described_class.add_weams_mailing_addresses(addresses, [weam1, weam], [])
      expect(addresses.count).to eq(1)
    end

    it 'does not includes a weam row without physical address when facility code was already grabbed' do
      weam = create(:weam, :mailing_address)
      weam1 = create(:weam, :no_mailing_address)

      addresses = []
      described_class.add_weams_mailing_addresses(addresses, [weam1, weam],
                                                  [weam.facility_code])
      expect(addresses.count).to eq(0)
    end
  end
end

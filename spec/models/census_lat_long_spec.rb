# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CensusLatLong, type: :model do

  describe "add_institution_addresses" do
    it "includes an institution missing lat long" do
      create :version
      create(:institution, :physical_address, version: Version.latest)
      create(:institution, :lat_long, version: Version.latest)

      addresses = []
      described_class.add_institution_addresses(addresses, [])
      expect(addresses.count).to eq(1)
    end

    it "does not include an institution missing lat long whose facility code also qualifies from weams" do
      create :version
      weam = create(:weam)
      create(:institution, facility_code: weam.facility_code, version: Version.latest)

      addresses = []
      described_class.add_institution_addresses(addresses, [weam.facility_code])
      expect(addresses.count).to eq(0)
    end
  end

  describe "add_weams_physical_addresses" do
    it "includes a weam row with physical address values" do
      weam = create(:weam, :no_physical_address)
      weam_1 = create(:weam, :physical_address)

      addresses = []
      described_class.add_weams_physical_addresses(addresses, [weam_1, weam])
      expect(addresses.count).to eq(1)
    end
  end

  describe "add_weams_mailing_addresses" do
    it "includes a weam row without physical address values" do
      weam = create(:weam)
      weam_1 = create(:weam, :physical_address)

      addresses = []
      described_class.add_weams_physical_addresses(addresses, [weam_1, weam])
      expect(addresses.count).to eq(1)
    end
  end
end

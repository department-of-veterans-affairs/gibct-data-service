require 'rails_helper'
require "support/shared_examples_for_csv_file_sti"

RSpec.describe MouCsvFile, type: :model do
  it_behaves_like "a csv file sti model", :hcm_csv_file

  describe "when creating an instance" do
    it "saves uploaded data to the hcm table" do
      csv = build :hcm_csv_file
      expect{ csv.save }.to change(Hcm, :count).by(2)
    end

    it "does not save if the data doesn't save to hcm" do
      csv = build :hcm_csv_file
      csv.upload.read
      expect{ csv.save }.to change(Hcm, :count).by(0)
      expect(csv.persisted?).to be_falsy
    end
  end
end
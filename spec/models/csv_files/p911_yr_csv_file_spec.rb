require 'rails_helper'
require "support/shared_examples_for_csv_file_sti"

RSpec.describe P911YrCsvFile, type: :model do
  it_behaves_like "a csv file sti model", :p911_yr_csv_file

  describe "when creating an instance" do
    it "saves uploaded data to the p911 yellow ribbon table" do
      csv = build :p911_yr_csv_file
      expect{ csv.save }.to change(P911Yr, :count).by(2)
    end

    it "does not save if the data doesn't save to p911 yellow ribbon" do
      csv = build :p911_yr_csv_file
      csv.upload.read
      expect{ csv.save }.to change(P911Yr, :count).by(0)
      expect(csv.persisted?).to be_falsy
    end
  end
end
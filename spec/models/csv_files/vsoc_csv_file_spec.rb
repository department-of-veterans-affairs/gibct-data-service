require 'rails_helper'
require "support/shared_examples_for_csv_file_sti"

RSpec.describe VsocCsvFile, type: :model do
  it_behaves_like "a csv file sti model", :vsoc_csv_file

  describe "when creating an instance" do
    it "saves uploaded data to the vsoc table" do
      csv = build :vsoc_csv_file
      expect{ csv.save }.to change(Vsoc, :count).by(2)
    end

    it "does not save if the data doesn't save to vsoc" do
      csv = build :vsoc_csv_file
      csv.upload.read
      expect{ csv.save }.to change(Vsoc, :count).by(0)
      expect(csv.persisted?).to be_falsy
    end
  end
end
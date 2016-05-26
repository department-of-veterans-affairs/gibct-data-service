require 'rails_helper'
require "support/shared_examples_for_csv_file_sti"

RSpec.describe ComplaintCsvFile, type: :model do
  it_behaves_like "a csv file sti model", :complaint_csv_file

  describe "when creating an instance" do
    it "saves uploaded data to the complaint table" do
      csv = build :complaint_csv_file
      expect{ csv.save }.to change(Complaint, :count).by(2)
    end

    it "does not save if the data doesn't save to complaint" do
      csv = build :complaint_csv_file
      csv.upload.read
      expect{ csv.save }.to change(Complaint, :count).by(0)
      expect(csv.persisted?).to be_falsy
    end

    it "calls update_sums_by_fac" do
      expect(Complaint).to receive(:update_sums_by_fac)
      create :complaint_csv_file
    end

    it "sets all OPE ids to nil" do
      create :complaint_csv_file
      expect(Complaint.pluck(:ope)).to eq([nil, nil])
      expect(Complaint.pluck(:ope6)).to eq([nil, nil])
    end
  end
end

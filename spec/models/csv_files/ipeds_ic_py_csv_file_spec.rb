require 'rails_helper'
require "support/shared_examples_for_csv_file_sti"

RSpec.describe IpedsIcPyCsvFile, type: :model do
  it_behaves_like "a csv file sti model", :ipeds_ic_py_csv_file

  describe "when creating an instance" do
    it "saves uploaded data to the ipeds_ic_py table" do
      csv = build :ipeds_ic_py_csv_file
      expect{ csv.save }.to change(IpedsIcPy, :count).by(2)
    end

    it "does not save if the data doesn't save to ipeds_ic_py" do
      csv = build :ipeds_ic_py_csv_file
      csv.upload.read
      expect{ csv.save }.to change(IpedsIcPy, :count).by(0)
      expect(csv.persisted?).to be_falsy
    end
  end

  describe "columns with periods only" do
    it "are ignored" do
      csv = create :ipeds_ic_py_csv_file_with_periods

      [:tutition_in_state, :tuition_out_of_state, :books].each do |col|
        expect(IpedsIcPy.first[col]).to be_nil
      end
    end
  end
end
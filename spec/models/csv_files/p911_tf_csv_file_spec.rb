require 'rails_helper'
require "support/shared_examples_for_csv_file_sti"

RSpec.describe P911TfCsvFile, type: :model do
  it_behaves_like "a csv file sti model", :p911_tf_csv_file

  describe "when creating an instance" do
    it "saves uploaded data to the weams table" do
      csv = build :p911_tf_csv_file
      expect{ csv.save }.to change(P911Tf, :count).by(2)
    end

    it "does not save if the data doesn't save to weams" do
      csv = build :p911_tf_csv_file
      csv.upload.read
      expect{ csv.save }.to change(P911Tf, :count).by(0)
      expect(csv.persisted?).to be_falsy
    end
  end
end
require 'rails_helper'
require "support/shared_examples_for_csv_file_sti"

RSpec.describe WeamsCsvFile, type: :model do
	it_behaves_like "a csv file sti model", :weams_csv_file

	describe "when creating an instance" do
  	it "saves uploaded data to the weams table" do
  		csv = build :weams_csv_file
  		expect{ csv.save }.to change(Weam, :count).by(2)
  	end

  	it "does not save if the data doesn't save to weams" do
  		csv = build :weams_csv_file
  		csv.upload.read
  		expect{ csv.save }.to change(Weam, :count).by(0)
  		expect(csv.persisted?).to be_falsy
  	end
  end
end
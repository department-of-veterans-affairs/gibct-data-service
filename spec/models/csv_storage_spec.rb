require 'rails_helper'

RSpec.describe CsvStorage, type: :model do
  context "with a factory" do
    it "that factory is valid" do
      expect(create(:csv_storage)).to be_valid
    end
  end

  context "csv_file_types" do
  	it "are required" do
    	expect{ create(:csv_storage, csv_file_type: nil) }.to raise_error(ActiveRecord::RecordInvalid)
  	end

	  it "are part of the CsvFile heirarchy" do
	    expect{ create :csv_storage, csv_file_type: "blah" }.to raise_error(ActiveRecord::RecordInvalid)
	  end

	  it "are unique" do
	  	create :csv_storage
	    expect{ create :csv_storage }.to raise_error(ActiveRecord::RecordInvalid)
	  end
	end
end

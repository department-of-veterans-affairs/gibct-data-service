require 'rails_helper'

RSpec.describe CsvFile, type: :model do
	subject { create(:raw_file_source).csv_file }

  describe "When creating" do
  	it "the associated raw file source must be unique" do
  		bad = CsvFile.new(raw_file_source_id: subject.raw_file_source_id)
  		expect(bad).not_to be_valid
  	end
  end
end
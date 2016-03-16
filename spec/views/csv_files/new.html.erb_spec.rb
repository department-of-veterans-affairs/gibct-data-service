require 'rails_helper'

RSpec.describe "csv_files/new.html.erb", type: :view do
  before(:each) do
  	assign(:csv_file, CsvFile.new);
  end

	it "displays empty CSV File form" do
		render
		expect(response.body).to match /upload a new csv file/im
	end
end
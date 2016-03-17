require 'rails_helper'

RSpec.describe "csv_types/index.html.erb", type: :view do
  before(:each) do
  	assign(:csv_types, CsvFile.types);
  end

  it "displays all the csv file types" do
  	render

  	CsvFile.types.each do |t|
  		expect(rendered).to match Regexp.new(t[0])
  		expect(rendered).to match Regexp.new(t[1])
  	end
  end
end

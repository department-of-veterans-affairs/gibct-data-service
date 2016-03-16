require 'rails_helper'

RSpec.describe "csv_files/index.html.erb", type: :view do
  before(:each) do
    @csv = create :weams_csv_file
  	assign(:csv_files, CsvFile.all);
  end

  it "displays all the csv files" do
  	render
  	expect(rendered).to match Regexp.new(@csv.name)
  end
end

require 'rails_helper'

RSpec.describe "csv_types/show.html.erb", type: :view do
	before(:each) do
    @csv_file = create :weams_csv_file

  	assign(:csv_type, CsvFile.types.first[1]);
    assign(:csv_files, CsvFile.where(type: CsvFile.types.first[1]))
    assign(:last_csv, CsvFile.where(type: CsvFile.types.first[1]).last_upload)
    assign(:humanized_csv_type, CsvFile.types.first[0])
  end

  it "displays the csv file type" do
  	render
  	expect(rendered).to match Regexp.new(CsvFile.types.first[0])
  end

  it "displays the csv file" do
    render
    expect(rendered).to match Regexp.new(@csv_file.name)   
  end
end

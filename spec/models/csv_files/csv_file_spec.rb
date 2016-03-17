require 'rails_helper'

RSpec.describe CsvFile, type: :model do
  describe "when creating" do
  	it "cannot be saved" do
  		expect(build :csv_file).not_to be_valid
  	end
  end

  describe "when deriving classes" do
		before(:all) do
			class FakeChild1 < CsvFile; end 
			class FakeChild2 < CsvFile; end 
		end

		it "returns a list of child models" do
			fc1 = ['Fake Child1', 'FakeChild1']
			fc2 = ['Fake Child2', 'FakeChild2']

			expect(CsvFile.types).to include(fc1, fc2)
		end
	end
end
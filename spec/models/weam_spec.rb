require 'rails_helper'

RSpec.describe Weam, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:weam)).to be_valid
      end
    end

    context "facility codes" do
    	subject { create :weam }

    	it "are unique" do
    		expect(build :weam, facility_code: subject.facility_code).not_to be_valid
    	end

    	it "are required" do
    		expect(build :weam, facility_code: nil).not_to be_valid
    	end
    end

    context "institution names" do
    	subject { create :weam }

    	it "are required" do
    		expect(build :weam, institution: nil).not_to be_valid
    	end
    end
  end

  describe "va highest degree offered" do
    {
      "10" => " ", "11" => "4-year", "12" => "4-year", 
      "13" => "4-year", "14" => "2-year", "15" => "NCD",
      "16" => "NCD", "17" => "NCD", "18" => "NCD", "19" => "NCD"
    }.each_pair do |facility_code, degree|
      it "returns '#{degree}' based on facility_code #{facility_code}" do
        weam = build :weam, facility_code: facility_code
        expect(weam.va_highest_degree_offered).to eq(degree)
      end
    end
  end
end

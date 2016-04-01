require 'rails_helper'

RSpec.describe Weam, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(build(:weam)).to be_valid
      end

      it "that factory is approved" do
        expect(build(:weam)).to be_approved
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

    context "state" do
      it "must be valid" do
        expect(build :weam, state: "ZZ").not_to be_valid
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

  describe "weams_type" do
    {
      flight: "Flight", foreign: "Foreign", correspondence: "Correspondence",
      ojt: "OJT", public: "Public", for_profit: "For Profit", private: "Private"
    }.each_pair do |weam, type|
      it "knows if its a #{type} institution" do
        expect(build(:weam, weam).weams_type).to eq(type)
      end
    end
  end

  describe "when approving" do
    [
      :non_approved_indicators, :non_approved_applicable_law_code_title_31,
      :non_approved_applicable_law_code_not_approved, :non_approved_poo
    ].each do |non_approved|
      it "will be non-approved when #{non_approved} are present" do
        expect(build :weam, non_approved).not_to be_approved
      end
    end

    it "can return only those approved weams records" do
      approved = create :weam

      [
        :non_approved_indicators, :non_approved_applicable_law_code_title_31,
        :non_approved_applicable_law_code_not_approved, :non_approved_poo
      ].each do |non_approved|
        create :weam, non_approved
      end

      expect(Weam.approved.count).to eq(1)
      expect(Weam.approved.first).to eq(approved)
    end
  end
end

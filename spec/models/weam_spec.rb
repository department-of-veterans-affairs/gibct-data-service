require 'rails_helper'

RSpec.describe Weam, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:weam)).to be_valid
      end

      it "that factory is approved" do
        expect(create(:weam).approved).to be_truthy
      end
    end

    describe "facility codes" do
    	subject { create :weam }

    	it "are unique" do
    		expect(build :weam, facility_code: subject.facility_code).not_to be_valid
    	end

    	it "are required" do
    		expect(build :weam, facility_code: nil).not_to be_valid
    	end
    end

    describe "institution names" do
    	it "are required" do
    		expect(build :weam, institution: nil).not_to be_valid
    	end
    end

    describe "correspondence" do
      it "is true when the school is a correspondence institution" do
        expect(create(:weam, :correspondence).correspondence).to be_truthy
        expect(create(:weam, :flight).correspondence).not_to be_truthy
      end
    end

    describe "flight" do
      it "is true when the school is a correspondence institution" do
        expect(create(:weam, :flight).flight).to be_truthy
        expect(create(:weam, :correspondence).flight).not_to be_truthy
      end
    end

    describe "va_highest_degree_offered" do
      {
        "10" => " ", "11" => "4-year", "12" => "4-year", 
        "13" => "4-year", "14" => "2-year", "15" => "NCD",
        "16" => "NCD", "17" => "NCD", "18" => "NCD", "19" => "NCD"
      }.each_pair do |facility_code, degree|
        it "returns '#{degree}' based on facility_code #{facility_code}" do
          weam = create :weam, facility_code: facility_code
          expect(weam.va_highest_degree_offered).to eq(degree)
        end
      end
    end

    describe "type" do
      {
        flight: "Flight", foreign: "Foreign", correspondence: "Correspondence",
        ojt: "OJT", public: "Public", for_profit: "For Profit", private: "Private"
      }.each_pair do |weam, type|
        it "knows if its a #{type} institution" do
          expect(create(:weam, weam).type).to eq(type)
        end
      end
    end

    describe "approved" do
      context "when poo, codes, and indicators are present and positive" do
        it "can return only those approved weams records" do
          approved = create :weam
      
          [
            :non_approved_indicators, :non_approved_applicable_law_code_title_31,
            :non_approved_applicable_law_code_not_approved, :non_approved_poo
          ].each do |non_approved|
            create :weam, non_approved
          end

          expect(Weam.where(approved: true).count).to eq(1)
          expect(Weam.where(approved: true).first).to be_truthy
        end
      end

      context "when poo, codes, and indicators are not present and negative" do
        [
          :non_approved_indicators, :non_approved_applicable_law_code_title_31,
          :non_approved_applicable_law_code_not_approved, :non_approved_poo
        ].each do |non_approved|
          it "will be non-approved when #{non_approved} are present" do
            expect(create(:weam, non_approved).approved).to be_falsy
          end
        end
      end
    end
  end
end

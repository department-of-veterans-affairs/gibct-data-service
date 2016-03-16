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
end

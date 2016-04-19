require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe ArfGibill, type: :model do
  it_behaves_like "a standardizable model", ArfGibill
  
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:arf_gibill)).to be_valid
      end
    end

    context "facility code" do
      subject { create :arf_gibill }

      it "is unique" do
        expect(build :arf_gibill, facility_code: subject.facility_code).not_to be_valid
      end

      it "is required" do
        expect(build :arf_gibill, facility_code: nil).not_to be_valid
      end
    end

    context "gibill" do
      it "is a number" do
        expect(build :arf_gibill, gibill: "abc").not_to be_valid
      end

      it "is required" do
        expect(build :arf_gibill, gibill: nil).not_to be_valid
      end
    end    
  end
end

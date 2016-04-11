require 'rails_helper'

RSpec.describe Hcm, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:hcm)).to be_valid
      end
    end
    
    context "ope" do
      it "is required" do
        expect(build :hcm, ope: nil).not_to be_valid
      end
    end

    context "hcm_type" do
      it "is required" do
        expect(build :hcm, hcm_type: nil).not_to be_valid
      end
    end

    context "hcm_reason" do
      it "is required" do
        expect(build :hcm, hcm_reason: nil).not_to be_valid
      end
    end
  end
end
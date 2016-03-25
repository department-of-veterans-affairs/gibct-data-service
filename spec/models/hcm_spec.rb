require 'rails_helper'

RSpec.describe Hcm, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:hcm)).to be_valid
      end
    end

    context "institution names" do
      it "are required" do
        expect(build :hcm, institution: nil).not_to be_valid
      end
    end
    
    context "ope ids" do
      it "are required" do
        expect(build :hcm, ope: nil).not_to be_valid
      end
    end

    context "monitor methods" do
      it "are required" do
        expect(build :hcm, monitor_method: nil).not_to be_valid
      end
    end

    context "reasons" do
      it "are required" do
        expect(build :hcm, reason: nil).not_to be_valid
      end
    end
  end
end
require 'rails_helper'

RSpec.describe Settlement, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:settlement)).to be_valid
      end
    end

    context "institution names" do
      it "are required" do
        expect(build :settlement, institution: nil).not_to be_valid
      end
    end
    
    context "ipeds ids" do
      it "are required" do
        expect(build :settlement, cross: nil).not_to be_valid
      end
    end

    context "settlement descriptions" do
      it "are required" do
        expect(build :settlement, settlement_description: nil).not_to be_valid
      end
    end
  end
end
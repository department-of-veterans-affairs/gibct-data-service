require 'rails_helper'

RSpec.describe Sva, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:sva)).to be_valid
      end
    end

    context "institution names" do
      it "are required" do
        expect(build :sva, institution: nil).not_to be_valid
      end
    end

    context "state" do
      it "must be valid" do
        expect(build :sva, state: "ZZ").not_to be_valid
      end
    end
  end
end

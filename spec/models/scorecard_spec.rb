require 'rails_helper'

RSpec.describe Scorecard, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:scorecard)).to be_valid
      end
    end

    context "cross (iped id)" do
      subject { create :scorecard }

      it "are required" do
        expect(build :scorecard, cross: nil).not_to be_valid
      end
    end

    context "ope id" do
      subject { create :scorecard }

      it "are required" do
        expect(build :scorecard, ope: nil).not_to be_valid
      end
    end
  end
end

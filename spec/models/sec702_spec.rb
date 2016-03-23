require 'rails_helper'

RSpec.describe Sec702, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:sec702)).to be_valid
      end
    end

    context "states" do
      subject { create :sec702 }

      it "are unique" do
        expect(build :sec702, state: subject.state).not_to be_valid
      end

      it "are required" do
        expect(build :sec702, state: nil).not_to be_valid
      end

      it "must be valid" do
        expect(build :sec702, state: "ZZ").not_to be_valid
      end
    end
  end
end

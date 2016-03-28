require 'rails_helper'

RSpec.describe IpedsIcAy, type: :model do
 describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:ipeds_ic_ay)).to be_valid
      end
    end

    context "cross" do
      subject { create :ipeds_ic_ay }

      it "are required" do
        expect(build :ipeds_ic_ay, cross: nil).not_to be_valid
      end
    end
  end
end

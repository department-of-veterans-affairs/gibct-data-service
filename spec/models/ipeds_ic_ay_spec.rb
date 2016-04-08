require 'rails_helper'

RSpec.describe IpedsIcAy, type: :model do
 describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:ipeds_ic_ay)).to be_valid
      end
    end

    context "cross" do
      it "is required" do
        expect(build :ipeds_ic_ay, cross: nil).not_to be_valid
      end
    end

    context "tuition_in_state" do
      it "must be an integer" do
        expect(build :ipeds_ic_ay, tuition_in_state: 2.0).not_to be_valid
      end
    end

    context "tuition_out_of_state" do
      it "must be an integer" do
        expect(build :ipeds_ic_ay, tuition_out_of_state: 2.0).not_to be_valid
      end
    end

    context "books" do
      it "must be an integer" do
        expect(build :ipeds_ic_ay, books: 2.0).not_to be_valid
      end
    end
  end
end

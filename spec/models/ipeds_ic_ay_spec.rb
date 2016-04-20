require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe IpedsIcAy, type: :model do
  it_behaves_like "a standardizable model", IpedsIcAy

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
      it "must be a number" do
        expect(build :ipeds_ic_ay, tuition_in_state: "abc").not_to be_valid
      end
    end

    context "tuition_out_of_state" do
      it "must be a number" do
        expect(build :ipeds_ic_ay, tuition_out_of_state: "abc").not_to be_valid
      end
    end

    context "books" do
      it "must be a number" do
        expect(build :ipeds_ic_ay, books: "abc").not_to be_valid
      end
    end
  end
end

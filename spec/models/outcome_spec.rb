require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe Outcome, type: :model do
  it_behaves_like "a standardizable model", Outcome

  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:outcome)).to be_valid
      end
    end

    context "facility_code" do
      subject { create :outcome }

      it "is unique" do
        expect(build :outcome, facility_code: subject.facility_code).not_to be_valid
      end

      it "is required" do
        expect(build :outcome, facility_code: nil).not_to be_valid
      end
    end

    context "retention_rate_veteran_ba" do
      it "must be an number" do
        expect(build :outcome, retention_rate_veteran_ba: "abc").not_to be_valid
      end
    end

    context "retention_rate_veteran_otb" do
      it "must be a number" do
        expect(build :outcome, retention_rate_veteran_otb: "abc").not_to be_valid
      end
    end

    context "persistance_rate_veteran_ba" do
      it "must be an number" do
        expect(build :outcome, retention_rate_veteran_ba: "abc").not_to be_valid
      end
    end

    context "persistance_rate_veteran_otb" do
      it "must be a number" do
        expect(build :outcome, retention_rate_veteran_otb: "abc").not_to be_valid
      end
    end

    context "graduation_rate_veteran" do
      it "must be an number" do
        expect(build :outcome, graduation_rate_veteran: "abc").not_to be_valid
      end
    end

    context "transfer_out_rate_veteran" do
      it "must be a number" do
        expect(build :outcome, transfer_out_rate_veteran: "abc").not_to be_valid
      end
    end
  end
end

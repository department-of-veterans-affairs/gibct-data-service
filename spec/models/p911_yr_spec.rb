require 'rails_helper'

RSpec.describe P911Yr, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:p911_yr)).to be_valid
      end
    end

    context "facility codes" do
      subject { create :p911_yr }

      it "are unique" do
        expect(build :p911_yr, facility_code: subject.facility_code).not_to be_valid
      end

      it "are required" do
        expect(build :p911_yr, facility_code: nil).not_to be_valid
      end
    end

    context "p911_yr_recipients" do
      it "must be an integer" do
        expect(build :p911_yr, p911_yr_recipients: 1.0).not_to be_valid
      end

      it "are required" do
        expect(build :p911_yr, p911_yr_recipients: nil).not_to be_valid
      end
    end

    context "p911_yellow_ribbon" do
      it "must be a number" do
        expect(build :p911_yr, p911_yellow_ribbon: 'abc').not_to be_valid
      end

      it "are required" do
        expect(build :p911_yr, p911_yellow_ribbon: nil).not_to be_valid
      end
    end
  end
end

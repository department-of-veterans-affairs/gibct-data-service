require 'rails_helper'

RSpec.describe P911Tf, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:p911_tf)).to be_valid
      end
    end

    context "facility_code" do
      subject { create :p911_tf }

      it "are unique" do
        expect(build :p911_tf, facility_code: subject.facility_code).not_to be_valid
      end

      it "are required" do
        expect(build :p911_tf, facility_code: nil).not_to be_valid
      end
    end

    context "p911_recipients" do
      it "must be an integer" do
        expect(build :p911_tf, p911_recipients: 1.0).not_to be_valid
      end

      it "are required" do
        expect(build :p911_tf, p911_recipients: nil).not_to be_valid
      end
    end

    context "p911_tuition_fees" do
      it "must be a number" do
        expect(build :p911_tf, p911_tuition_fees: 'abc').not_to be_valid
      end

      it "are required" do
        expect(build :p911_tf, p911_tuition_fees: nil).not_to be_valid
      end
    end
  end
end

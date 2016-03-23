require 'rails_helper'

RSpec.describe P911Tf, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:p911_tf)).to be_valid
      end
    end

    context "facility codes" do
      subject { create :p911_tf }

      it "are unique" do
        expect(build :p911_tf, facility_code: subject.facility_code).not_to be_valid
      end

      it "are required" do
        expect(build :p911_tf, facility_code: nil).not_to be_valid
      end
    end

    context "institution names" do
      it "are required" do
        expect(build :p911_tf, institution: nil).not_to be_valid
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Vsoc, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:vsoc)).to be_valid
      end
    end

    context "facility codes" do
      subject { create :vsoc }

      it "are unique" do
        expect(build :vsoc, facility_code: subject.facility_code).not_to be_valid
      end

      it "are required" do
        expect(build :vsoc, facility_code: nil).not_to be_valid
      end
    end

    context "institution names" do
      it "are required" do
        expect(build :vsoc, institution: nil).not_to be_valid
      end
    end
  end
end

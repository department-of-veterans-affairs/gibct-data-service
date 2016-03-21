require 'rails_helper'

RSpec.describe VaCrosswalk, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:va_crosswalk)).to be_valid
      end
    end

    context "facility codes" do
      subject { create :va_crosswalk }

      it "are unique" do
        expect(build :va_crosswalk, facility_code: subject.facility_code).not_to be_valid
      end

      it "are required" do
        expect(build :va_crosswalk, facility_code: nil).not_to be_valid
      end
    end

    context "institution names" do
      subject { create :va_crosswalk }

      it "are required" do
        expect(build :va_crosswalk, institution: nil).not_to be_valid
      end
    end
  end
end

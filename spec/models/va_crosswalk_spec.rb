require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe VaCrosswalk, type: :model do
  it_behaves_like "a standardizable model", VaCrosswalk
  
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:va_crosswalk)).to be_valid
      end
    end

    context "facility codes" do
      subject { create :va_crosswalk }

      it "is unique" do
        expect(build :va_crosswalk, facility_code: subject.facility_code).not_to be_valid
      end

      it "is required" do
        expect(build :va_crosswalk, facility_code: nil).not_to be_valid
      end
    end
  end
end

require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe Sec702School, type: :model do
  it_behaves_like "a standardizable model", Sec702School

  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:sec702_school)).to be_valid
      end
    end

    context "facility_code" do
      subject { create :sec702_school }

      it "is unique" do
        expect(build :sec702_school, facility_code: subject.facility_code).not_to be_valid
      end

      it "is required" do
        expect(build :sec702_school, facility_code: nil).not_to be_valid
      end
    end
  end
end

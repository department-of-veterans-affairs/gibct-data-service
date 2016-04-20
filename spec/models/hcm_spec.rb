require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe Hcm, type: :model do
  it_behaves_like "a standardizable model", Hcm

  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:hcm)).to be_valid
      end
    end
    
    context "ope" do
      it "is required" do
        expect(build :hcm, ope: nil).not_to be_valid
      end
    end

    context "hcm_type" do
      it "is required" do
        expect(build :hcm, hcm_type: nil).not_to be_valid
      end
    end

    context "hcm_reason" do
      it "is required" do
        expect(build :hcm, hcm_reason: nil).not_to be_valid
      end
    end
  end
end
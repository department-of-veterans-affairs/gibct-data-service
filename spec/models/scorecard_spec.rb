require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe Scorecard, type: :model do
  it_behaves_like "a standardizable model", Scorecard

  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:scorecard)).to be_valid
      end
    end

    context "cross" do
      it "is required" do
        expect(build :scorecard, cross: nil).not_to be_valid
      end
    end

    context "ope" do
      it "is required" do
        expect(build :scorecard, ope: nil).not_to be_valid
      end
    end

    context "graduation_rate_all_students" do
      it "prefers the value of c150_4_pooled_supp" do
        sc = create(:scorecard)
        expect(sc.graduation_rate_all_students).to eq(sc.c150_4_pooled_supp)
      end

      it "uses the value of c200_l4_pooled_supp if c150_4_pooled_supp is nil" do
        sc = create(:scorecard, c150_4_pooled_supp: nil)
        expect(sc.graduation_rate_all_students).to eq(sc.c200_l4_pooled_supp)
      end 

      it "is nil if both c150_4_pooled_supp and c200_l4_pooled_supp are nil" do
        sc = create(:scorecard, c150_4_pooled_supp: nil, c200_l4_pooled_supp: nil)
        expect(sc.graduation_rate_all_students).to be_nil
      end     
    end
  end
end

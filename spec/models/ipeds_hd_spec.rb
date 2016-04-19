require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe IpedsHd, type: :model do
  it_behaves_like "a standardizable model", IpedsHd

  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:ipeds_hd)).to be_valid
      end
    end

    context "cross" do
      subject { create :ipeds_hd }

      it "are required" do
        expect(build :ipeds_hd, cross: nil).not_to be_valid
      end
    end
  end
end

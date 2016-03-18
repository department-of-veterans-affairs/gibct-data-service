require 'rails_helper'

RSpec.describe EightKey, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:eight_key)).to be_valid
      end
    end

    context "institution names" do
      subject { create :eight_key }

      it "are required" do
        expect(build :eight_key, institution: nil).not_to be_valid
      end
    end
  end
end

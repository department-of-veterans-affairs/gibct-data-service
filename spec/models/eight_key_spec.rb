require 'rails_helper'

RSpec.describe EightKey, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:eight_key)).to be_valid
      end
    end
  end
end

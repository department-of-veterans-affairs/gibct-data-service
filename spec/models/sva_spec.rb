require 'rails_helper'

RSpec.describe Sva, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:sva)).to be_valid
      end
    end
  end
end

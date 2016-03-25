require 'rails_helper'

RSpec.describe Mou, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:mou)).to be_valid
      end
    end

    context "institution names" do
      it "are required" do
        expect(build :mou, institution: nil).not_to be_valid
      end
    end
    
    context "ope ids" do
      it "are required" do
        expect(build :mou, ope: nil).not_to be_valid
      end
    end
  end
end

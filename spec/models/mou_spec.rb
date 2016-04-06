require 'rails_helper'

RSpec.describe Mou, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:mou)).to be_valid
      end
    end
    
    context "ope" do
      it "is required" do
        expect(build :mou, ope: nil).not_to be_valid
      end
    end

    context "dodmou" do
      Mou::STATUSES.each do |status|
        it "is true if status matches '#{status}'" do
          expect(create(:mou, status: status).dodmou).to be_truthy
        end
      end

      it "is false if status does not match known statuses" do
        expect(create(:mou, status: "").dodmou).to be_falsy
      end
    end
  end
end

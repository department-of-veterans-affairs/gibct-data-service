require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe Mou, type: :model do
  it_behaves_like "a standardizable model", Mou

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
        it "is false if status matches '#{status}'" do
          expect(create(:mou, status: status.upcase).dodmou).not_to be_truthy
        end
      end

      it "is true if status does not match known statuses" do
        expect(create(:mou, status: "").dodmou).to be_truthy
      end
    end

    context "dod_status" do
      it "is true if status matches 'probation - dod'" do
        expect(create(:mou, status: 'PrObAtIoN - Dod').dod_status).to be_truthy
      end

      it "is false if status does not match 'probation - dod'" do
        expect(create(:mou, status: "blah blah").dod_status).to be_falsy
      end
    end
  end
end

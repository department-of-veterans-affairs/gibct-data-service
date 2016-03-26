require 'rails_helper'

RSpec.describe IpedsIc, type: :model do
 describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:ipeds_ic)).to be_valid
      end
    end

    context "cross" do
      subject { create :ipeds_ic }

      it "are required" do
        expect(build :ipeds_ic, cross: nil).not_to be_valid
      end
    end

    context "vet3" do
      subject { create :ipeds_ic }

      it "are required" do
        expect(build :ipeds_ic, vet3: nil).not_to be_valid
      end
    end

    context "vet4" do
      subject { create :ipeds_ic }

      it "are required" do
        expect(build :ipeds_ic, vet4: nil).not_to be_valid
      end
    end

    context "vet5" do
      subject { create :ipeds_ic }

      it "are required" do
        expect(build :ipeds_ic, vet5: nil).not_to be_valid
      end
    end

    context "vet2" do
      subject { create :ipeds_ic }

      it "are required" do
        expect(build :ipeds_ic, vet2: nil).not_to be_valid
      end
    end

    context "calsys" do
      subject { create :ipeds_ic }

      it "are required" do
        expect(build :ipeds_ic, calsys: nil).not_to be_valid
      end
    end

    context "csv_online_all" do
      subject { create :ipeds_ic }

      it "are required" do
        expect(build :ipeds_ic, distnced: nil).not_to be_valid
      end
    end
  end
end

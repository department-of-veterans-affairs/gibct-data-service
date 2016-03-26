require 'rails_helper'

RSpec.describe Accreditation, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:accreditation)).to be_valid
      end
    end

    context "agency names" do
      it "are required" do
        expect(build :accreditation, agency_name: nil).not_to be_valid
      end
    end

    context "csv accreditation types" do
      it "are required" do
        expect(build :accreditation, csv_accreditation_type: nil).not_to be_valid
      end

      it "must be from a list of values" do
        expect(build :accreditation, csv_accreditation_type: "blah-blah").not_to be_valid
      end
    end

    context "last action" do
      it "are not required" do
        expect(build :accreditation, accreditation_status: nil).to be_valid
      end

      it "must be from a list of values" do
        expect(build :accreditation, accreditation_status: "blah-blah").not_to be_valid
      end
    end

    context "institution" do
      subject { create :accreditation }

      it "gets campus_name if it is not nil" do
        expect(subject.institution).to eq(subject.campus_name)
      end

      it "gets the institution name if the campus name is nil" do
        subject.campus_name = nil
        expect(subject.institution).to eq(subject.institution_name)
      end
    end

    context "ipeds" do
      subject { create :accreditation }

      it "gets institution ipeds id if it is not nil" do
        expect(subject.cross).to eq(subject.institution_ipeds_unitid)
      end

      it "gets the campus ipeds if the institution ipeds is nil" do
        subject.institution_ipeds_unitid = nil
        expect(subject.cross).to eq(subject.campus_ipeds_unitid)
      end
    end

    context "accreditation_status" do
      it "gets the accreditation status (accreditation_status)" do
        expect(subject.accreditation_status).to eq(subject.accreditation_status)
      end
    end

    context "accreditation_type" do
      subject { create :accreditation }

      it "gets the accreditation type (according to the GIBCT)" do
        Accreditation::ACCREDITATIONS.keys.each do |key|
          Accreditation::ACCREDITATIONS[key].each do |exp|
            subject.agency_name = "BLAH #{exp}"
            expect(subject.accreditation_type).to eq(key)
          end
        end

        subject.agency_name = "BLAH BLAH"
        expect(subject.accreditation_type).to be_nil
      end
    end
  end
end

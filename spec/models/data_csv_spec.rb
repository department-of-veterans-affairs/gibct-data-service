require 'rails_helper'

RSpec.describe DataCsv, type: :model do
  subject { DataCsv.find_by(facility_code: approved.facility_code) }

  let!(:approved) { create :weam }
  let!(:unapproved) { create :weam, :non_approved_poo }
  let!(:crosswalk) { create :va_crosswalk, facility_code: approved.facility_code }

  before(:each) do
    DataCsv.initialize_with_weams 
    DataCsv.update_with_crosswalk
  end

  describe "when initializing" do 
    context "with weams" do
      it "is seeded by approved weams schools" do      
        expect(subject).not_to be_nil
      end

      it "does not contain unapproved schools" do
        expect(DataCsv.find_by(facility_code: unapproved.facility_code)).to be_nil
      end

      
      Weam::USE_COLUMNS.each do |column|
        it "contains the #{column} column" do
            expect(subject[column]).to eq(approved[column])
        end
      end
    end
  end

  describe "when updating" do
    context "with the crosswalk" do
      it "is matches by facility_code" do
        data = DataCsv.find_by(facility_code: crosswalk.facility_code)
        expect(data).not_to be_nil
      end

      VaCrosswalk::USE_COLUMNS.each do |column|
        it "contains the #{column} column" do
          expect(subject[column]).to eq(crosswalk[column])
        end
      end
    end
  end
end

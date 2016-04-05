require 'rails_helper'

RSpec.describe DataCsv, type: :model do
  subject { DataCsv.find_by(facility_code: approved.facility_code) }

  let!(:approved) { create :weam }
  let!(:unapproved) { create :weam, :non_approved_poo }
  let!(:unmatched) { create :weam }

  describe "when initializing" do 
    before(:each) do
      DataCsv.initialize_with_weams 
    end

    context "with weams" do
      it "contains only approved institutions" do      
        expect(subject).not_to be_nil
      end

      it "does not contain any unapproved institutions" do
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
    context "with crosswalks" do
      let!(:crosswalk) { create :va_crosswalk, facility_code: approved.facility_code }

      before(:each) do
        DataCsv.initialize_with_weams 
        DataCsv.update_with_crosswalk
      end

      it "is matched by facility_code" do
        data = DataCsv.find_by(facility_code: crosswalk.facility_code)
        expect(data).not_to be_nil
      end

      VaCrosswalk::USE_COLUMNS.each do |column|
        it "contains the #{column} column" do
          expect(subject[column]).to eq(crosswalk[column])
        end
      end
    end

    context "with svas" do
      let!(:crosswalk) { create :va_crosswalk, facility_code: approved.facility_code }

      let!(:sva) { create :sva, cross: crosswalk.cross }
      let!(:sva_with_nil_cross) { create :sva, cross: nil, institution: "eudshynilcross" }

      before(:each) do
        DataCsv.initialize_with_weams 
        DataCsv.update_with_crosswalk
        DataCsv.update_with_sva
      end

      it "is matched by a non-null ipeds" do
        data = DataCsv.find_by(cross: sva.cross)
        expect(data).not_to be_nil
      end

      it "null ipeds are not matched" do
        d = DataCsv.find_by(facility_code: unmatched.facility_code)
        expect(d.student_veteran).to be_falsy
      end

      Sva::USE_COLUMNS.each do |column|
        it "contains the #{column} column" do
          expect(subject[column]).to eq(sva[column])
        end
      end

      it "contains the student_veteran column" do
        expect(subject.student_veteran).to be_truthy
      end
    end

    context "with vsocs" do
      let!(:vsoc) { create :vsoc, facility_code: approved.facility_code }

      before(:each) do
        DataCsv.initialize_with_weams 
        DataCsv.update_with_crosswalk
        DataCsv.update_with_vsoc
      end

      it "is matched by facility_code" do
        data = DataCsv.find_by(facility_code: vsoc.facility_code)
        expect(data).not_to be_nil
      end

      Vsoc::USE_COLUMNS.each do |column|
        it "contains the #{column} column" do
          expect(subject[column]).to eq(vsoc[column])
        end
      end
    end

    context "with eight_keys" do
      let!(:crosswalk) { create :va_crosswalk, facility_code: approved.facility_code }
 
      let!(:eight_key_ipeds) { create :eight_key, ope: nil, cross: crosswalk.cross }
      let!(:eight_key_with_nil_cross) { create :eight_key, ope: nil, cross: nil }

      before(:each) do
        DataCsv.initialize_with_weams 
        DataCsv.update_with_crosswalk
        DataCsv.update_with_eight_key
      end

      it "is matched by ipeds" do
        data = DataCsv.find_by(cross: eight_key_ipeds.cross)
        expect(data).not_to be_nil
        expect(data.eight_keys).to be_truthy
      end

      it "null ipeds are not matched" do
        d = DataCsv.find_by(facility_code: unmatched.facility_code)
        expect(d.eight_keys).to be_falsy
      end
    end
  end
end

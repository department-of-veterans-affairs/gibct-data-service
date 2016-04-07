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
      let!(:crosswalk) { create :va_crosswalk, facility_code: approved.facility_code }
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
 
      let!(:eight_key) { create :eight_key, ope: nil, cross: crosswalk.cross }
      let!(:eight_key_with_nil_cross) { create :eight_key, ope: nil, cross: nil }

      before(:each) do
        DataCsv.initialize_with_weams 
        DataCsv.update_with_crosswalk
        DataCsv.update_with_eight_key
      end

      it "is matched by ipeds" do
        data = DataCsv.find_by(cross: eight_key.cross)
        expect(data).not_to be_nil
        expect(data.eight_keys).to be_truthy
      end

      it "null ipeds are not matched" do
        d = DataCsv.find_by(facility_code: unmatched.facility_code)
        expect(d.eight_keys).to be_falsy
      end
    end

    context "with accreditations" do
      let!(:not_institutional) { create :weam }
      let!(:not_current) { create :weam }

      let!(:crosswalk) { create :va_crosswalk, facility_code: approved.facility_code }
      let(:crosswalk_for_not_institutional) { create :va_crosswalk, facility_code: not_institutional.facility_code }
      let(:crosswalk_for_not_current) { create :va_crosswalk, facility_code: not_current.facility_code }
 
      let!(:accreditation) { create :accreditation, ope: nil, campus_ipeds_unitid: crosswalk.cross }
      let!(:accreditation_with_nil_cross) { create :accreditation, ope: nil, campus_ipeds_unitid: nil }
      let!(:accreditation_not_institutional) { 
        create :accreditation, :not_institutional, campus_ipeds_unitid: crosswalk_for_not_institutional.cross 
      }
      let!(:accreditation_not_current) { 
        create :accreditation, :not_current, campus_ipeds_unitid: crosswalk_for_not_current.cross 
      }

      before(:each) do
        DataCsv.initialize_with_weams 
        DataCsv.update_with_crosswalk
        DataCsv.update_with_accreditation
      end

      it "is matched by ipeds" do
        data = DataCsv.find_by(cross: accreditation.cross)
        expect(data).not_to be_nil
        expect(data.accreditation_status).to eq(accreditation.accreditation_status)
        expect(data.accreditation_type).to eq(accreditation.accreditation_type)
      end

      it "null ipeds are not matched" do
        data = DataCsv.find_by(facility_code: unmatched.facility_code)
        expect(data.accreditation_status).to be_nil
        expect(data.accreditation_type).to be_nil
      end

      it "accreditation_type is nil if csv_accreditation_type is not institutional" do
        data = DataCsv.find_by(cross: accreditation_not_institutional.cross)
        expect(data.accreditation_status).to be_nil
        expect(data.accreditation_type).to be_nil
      end

      it "accreditation_type is nil if periods is not current" do
        data = DataCsv.find_by(cross: accreditation_not_current.cross)
        expect(data.accreditation_status).to be_nil
        expect(data.accreditation_type).to be_nil
      end
    end

    context "with arf_gibills" do
      let!(:crosswalk) { create :va_crosswalk, facility_code: approved.facility_code }
      let!(:arf_gibill) { create :arf_gibill, facility_code: approved.facility_code }

      before(:each) do
        DataCsv.initialize_with_weams 
        DataCsv.update_with_crosswalk
        DataCsv.update_with_arf_gibill
      end

      it "is matched by facility_code" do
        data = DataCsv.find_by(facility_code: arf_gibill.facility_code)
        expect(data).not_to be_nil
      end

      ArfGibill::USE_COLUMNS.each do |column|
        it "contains the #{column} column" do
          expect(subject[column]).to eq(arf_gibill[column])
        end
      end
    end

    context "with p911_tfs" do
      let!(:crosswalk) { create :va_crosswalk, facility_code: approved.facility_code }
      let!(:p911_tf) { create :p911_tf, facility_code: approved.facility_code }

      before(:each) do
        DataCsv.initialize_with_weams 
        DataCsv.update_with_crosswalk
        DataCsv.update_with_p911_tf
      end

      it "is matched by facility_code" do
        data = DataCsv.find_by(facility_code: p911_tf.facility_code)
        expect(data).not_to be_nil
      end

      P911Tf::USE_COLUMNS.each do |column|
        it "contains the #{column} column" do
          expect(subject[column]).to eq(p911_tf[column])
        end
      end
    end

    context "with p911_tfs" do
      let!(:crosswalk) { create :va_crosswalk, facility_code: approved.facility_code }
      let!(:p911_yr) { create :p911_yr, facility_code: approved.facility_code }

      before(:each) do
        DataCsv.initialize_with_weams 
        DataCsv.update_with_crosswalk
        DataCsv.update_with_p911_yr
      end

      it "is matched by facility_code" do
        data = DataCsv.find_by(facility_code: p911_yr.facility_code)
        expect(data).not_to be_nil
      end

      P911Yr::USE_COLUMNS.each do |column|
        it "contains the #{column} column" do
          expect(subject[column]).to eq(p911_yr[column])
        end
      end
    end

    context "with mous" do
      let!(:crosswalk) { create :va_crosswalk, facility_code: approved.facility_code }
      let!(:mou) { create :mou, ope: crosswalk.ope }

      before(:each) do
        DataCsv.initialize_with_weams 
        DataCsv.update_with_crosswalk
        DataCsv.update_with_mou
      end

      it "is matched by ope6" do
        data = DataCsv.find_by(ope6: mou.ope6)
        expect(data).not_to be_nil
      end

      Mou::USE_COLUMNS.each do |column|
        it "contains the #{column} column" do
          expect(subject[column]).to eq(mou[column])
        end
      end
    end

    context "with scorecards" do
      let!(:crosswalk) { create :va_crosswalk, facility_code: approved.facility_code }
      let!(:scorecard) { create :scorecard, ope: crosswalk.ope, cross: crosswalk.cross }

      before(:each) do
        DataCsv.initialize_with_weams 
        DataCsv.update_with_crosswalk
        DataCsv.update_with_scorecard
      end

      it "is matched by cross" do
        data = DataCsv.find_by(cross: scorecard.cross)
        expect(data).not_to be_nil
      end

      Scorecard::USE_COLUMNS.each do |column|
        it "contains the #{column} column" do
          expect(subject[column]).to eq(scorecard[column])
        end
      end
    end

    context "with ipeds_ics" do
      let!(:crosswalk) { create :va_crosswalk, facility_code: approved.facility_code }
      let!(:ipeds_ic) { create :ipeds_ic, cross: crosswalk.cross }

      before(:each) do
        DataCsv.initialize_with_weams 
        DataCsv.update_with_crosswalk
        DataCsv.update_with_ipeds_ic
      end

      it "is matched by cross" do
        data = DataCsv.find_by(cross: ipeds_ic.cross)
        expect(data).not_to be_nil
      end

      IpedsIc::USE_COLUMNS.each do |column|
        it "contains the #{column} column" do
          expect(subject[column]).to eq(ipeds_ic[column])
        end
      end
    end

    context "with ipeds_hds" do
      let!(:crosswalk) { create :va_crosswalk, facility_code: approved.facility_code }
      let!(:ipeds_hd) { create :ipeds_hd, cross: crosswalk.cross }

      before(:each) do
        DataCsv.initialize_with_weams 
        DataCsv.update_with_crosswalk
        DataCsv.update_with_ipeds_hd
      end

      it "is matched by cross" do
        data = DataCsv.find_by(cross: ipeds_hd.cross)
        expect(data).not_to be_nil
      end

      IpedsHd::USE_COLUMNS.each do |column|
        it "contains the #{column} column" do
          expect(subject[column]).to eq(ipeds_hd[column])
        end
      end
    end

    context "with ipeds_ic_ays" do
      let!(:crosswalk) { create :va_crosswalk, facility_code: approved.facility_code }
      let!(:ipeds_ic_ay) { create :ipeds_ic_ay, cross: crosswalk.cross }

      before(:each) do
        DataCsv.initialize_with_weams 
        DataCsv.update_with_crosswalk
        DataCsv.update_with_ipeds_ic_ay
      end

      it "is matched by cross" do
        data = DataCsv.find_by(cross: ipeds_ic_ay.cross)
        expect(data).not_to be_nil
      end

      IpedsIcAy::USE_COLUMNS.each do |column|
        it "contains the #{column} column" do
          expect(subject[column]).to eq(ipeds_ic_ay[column])
        end
      end
    end
  end
end

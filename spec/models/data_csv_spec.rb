require 'rails_helper'

RSpec.describe DataCsv, type: :model do
  #############################################################################
  ## Common Definitions
  #############################################################################
  let!(:weam_approved_public) { create :weam, :public, state: 'NY' }
  let!(:weam_approved_private) { create :weam, :private, state: 'NJ' }
  let!(:weam_unapproved) { create :weam, :non_approved_poo, state: 'OH' }
  let!(:weam_unmatched) { create :weam, state: 'CA' }

  let!(:crosswalk_approved_public) do
    create :va_crosswalk, facility_code: weam_approved_public.facility_code 
  end
  let!(:crosswalk_approved_private) do
    create :va_crosswalk, facility_code: weam_approved_private.facility_code 
  end
  let!(:crosswalk_unapproved) do
    create :va_crosswalk, facility_code: weam_unapproved.facility_code 
  end
  let!(:crosswalk_unmatched) do
    create :va_crosswalk, facility_code: weam_unmatched.facility_code 
  end

  #############################################################################
  ## Common Setup
  #############################################################################
  before(:each) do
    DataCsv.initialize_with_weams 
    DataCsv.update_with_crosswalk 
  end

  #############################################################################
  ## initialize_with_weams
  #############################################################################
  describe "initialize_with_weams" do
    let(:fcs) { DataCsv.all.pluck(:facility_code) }

    describe "when approving" do
      it "updates approved institutions" do        
        expect(fcs).to contain_exactly(
          weam_approved_public.facility_code,
          weam_approved_private.facility_code,
          weam_unmatched.facility_code
        )  
      end

      it "does not update any unapproved institutions" do
        expect(fcs).not_to include(weam_unapproved.facility_code)
      end
    end

    describe "when copying fields to data_csv" do
      Weam::USE_COLUMNS.each do |column|
        it "sets the #{column} column" do
          DataCsv.all.each do |data|
            weam = Weam.find_by(facility_code: data.facility_code)
            expect(data[column]).to eq(weam[column])
          end
        end
      end
    end
  end

  #############################################################################
  ## update_with_crosswalk
  #############################################################################
  describe "update_with_crosswalk" do  
    let(:approved) do 
      [
        crosswalk_approved_public, 
        crosswalk_approved_private, 
        crosswalk_unmatched
      ]
    end 

    describe "when matching" do
      it "matches facility_code to approved schools in data_csv" do
        approved.each do |crosswalk|
          data = DataCsv.find_by(facility_code: crosswalk.facility_code)
          expect(data).not_to be_nil
        end
      end

      it "dosen't match to unnapproved schools" do
        data = DataCsv.find_by(facility_code: crosswalk_unapproved.facility_code)
        expect(data).to be_nil
      end
    end

    describe "when copying fields to data_csv" do
      VaCrosswalk::USE_COLUMNS.each do |column|
        it "updates the #{column} column" do
          DataCsv.all.each do |data|
            crosswalk = VaCrosswalk.find_by(facility_code: data.facility_code)
            expect(data[column]).to eq(crosswalk[column])
          end
        end
      end
    end
  end

  #############################################################################
  ## update_with_sva
  #############################################################################
  describe "update_with_sva" do
    let!(:sva) { create :sva, cross: crosswalk_approved_public.cross }
    let!(:sva_nil_cross) { create :sva, cross: nil, institution: "nilcross" }

    let(:data) { DataCsv.find_by(cross: sva.cross) }

    before(:each) do
      DataCsv.update_with_sva
    end

    describe "when matching" do
      it "matches cross to approved schools in data_csv" do
        expect(data).not_to be_nil

        data = DataCsv.find_by(cross: sva_nil_cross.cross)
        expect(data).to be_nil    
      end
    end

    describe "when copying fields to data_csv" do
      Sva::USE_COLUMNS.each do |column|
        it "updates the #{column} column" do
          expect(data[column]).to eq(sva[column])
        end
      end

      it "updates data_csv.student_veteran to true" do
        expect(data.student_veteran).to be_truthy
      end
    end
  end

  #############################################################################
  ## update_with_vsoc
  #############################################################################
  describe "update_with_vsoc" do
    let!(:vsoc) do 
      create :vsoc, facility_code: crosswalk_approved_public.facility_code 
    end

    let(:data) { DataCsv.find_by(facility_code: vsoc.facility_code) }

    before(:each) do
      DataCsv.update_with_vsoc
    end

    describe "when matching" do
      it "matches facility_code to approved schools in data_csv" do
        expect(data).not_to be_nil
      end
    end

    describe "when copying fields to data_csv" do
      Vsoc::USE_COLUMNS.each do |column|
        it "updates the #{column} column" do
          expect(data[column]).to eq(vsoc[column])
        end
      end
    end
  end

  #############################################################################
  ## update_with_eight_key
  #############################################################################
  describe "update_with_eight_key" do
    let!(:eight_key) do 
      create :eight_key, cross: crosswalk_approved_public.cross 
    end

    let!(:eight_key_nil_cross) { create :eight_key, cross: nil }

    let(:data) { DataCsv.find_by(cross: eight_key.cross) }

    before(:each) do
      DataCsv.update_with_eight_key
    end

    describe "when matching" do
      it "matches cross to approved schools in data_csv" do
        expect(data).not_to be_nil

        data = DataCsv.find_by(cross: eight_key_nil_cross)
        expect(data).to be_nil        
      end
    end

    describe "when copying fields to data_csv" do
      it "updates data_csv.eight_key to true" do
        expect(data.eight_keys).to be_truthy
      end
    end
  end

  #############################################################################
  ## update_with_accreditation
  #############################################################################
  describe "update_with_accreditation" do
    let(:data) { DataCsv.find_by(cross: accreditation.cross) }

    describe "when matching" do
      context "and is institutional and current" do
        let!(:accreditation) do 
          create :accreditation, 
            campus_ipeds_unitid: crosswalk_approved_public.cross
        end

        let!(:accreditation_nil_cross) do 
          create :accreditation, campus_ipeds_unitid: nil
        end

        before(:each) do
          DataCsv.update_with_accreditation
        end

        it "matches cross to approved schools in data_csv" do
          expect(data).not_to be_nil

          data = DataCsv.find_by(cross: accreditation_nil_cross.cross)
          expect(data).to be_nil
        end
      end
    end

    describe "when copying fields to data_csv" do
      context "and is institutional and current" do
        let!(:accreditation) do 
          create :accreditation, 
            campus_ipeds_unitid: crosswalk_approved_public.cross
        end

        before(:each) do
          DataCsv.update_with_accreditation
        end

        Accreditation::USE_COLUMNS.each do |column|
          it "updates the #{column} column" do
            expect(data[column]).to eq(accreditation[column])
          end
        end
      end

      [:not_institutional, :not_current].each do |trait|
        context "and is #{trait.to_s.humanize.downcase}" do
          let!(:accreditation) do 
            create :accreditation, trait,
              campus_ipeds_unitid: crosswalk_approved_public.cross
          end

          before(:each) do
            DataCsv.update_with_accreditation
          end

          Accreditation::USE_COLUMNS.each do |column|
            it "does not match cross to approved schools in data_csv" do
              expect(data[column]).to be_nil
            end
          end
        end
      end
    end

    describe "when setting data_csv.caution_flag" do
      context "and is institutional, and current" do
        context "and the accreditation_status is not nil" do
          let!(:accreditation) do 
            create :accreditation, 
              campus_ipeds_unitid: crosswalk_approved_public.cross
          end

          before(:each) do
            DataCsv.update_with_accreditation
          end

          it "sets the data_csv.caution_flag true " do
            expect(data.caution_flag).to be_truthy
          end
        end

        context "and the accreditation_status is nil" do
          let!(:accreditation) do 
            create :accreditation, accreditation_status: nil,
              campus_ipeds_unitid: crosswalk_approved_public.cross
          end

          before(:each) do
            DataCsv.update_with_accreditation
          end

          it "leaves the data_csv.caution_flag as it was" do
            expect(data.caution_flag).to be_nil
          end
        end
      end   

      [:not_institutional, :not_current].each do |trait|
        context "and is #{trait.to_s.humanize.downcase}" do
          let!(:accreditation) do 
            create :accreditation, trait,
              campus_ipeds_unitid: crosswalk_approved_public.cross
          end

          before(:each) do
            DataCsv.update_with_accreditation
          end

          it "leaves the data_csv.caution_flag as it was" do
            expect(data.caution_flag).to be_nil
          end
        end 
      end
    end

    describe "when setting data_csv.caution_flag_reason" do
      context "and is institutional, and current" do
        context "and the accreditation_status is not nil" do
          let!(:accreditation) do 
            create :accreditation, 
              campus_ipeds_unitid: crosswalk_approved_public.cross
          end

          before(:each) do
            DataCsv.update_with_accreditation
          end

          it "appends data_csv.caution_flag_reason true " do
            expect(data.caution_flag_reason).not_to be_nil
          end
        end

        context "and the accreditation_status is nil" do
          let!(:accreditation) do 
            create :accreditation, accreditation_status: nil,
              campus_ipeds_unitid: crosswalk_approved_public.cross
          end

          before(:each) do
            DataCsv.update_with_accreditation
          end

          it "leaves the data_csv.caution_flag as it was" do
            expect(data.caution_flag).to be_nil
          end
        end
      end   

      [:not_institutional, :not_current].each do |trait|
        context "and is #{trait.to_s.humanize.downcase}" do
          let!(:accreditation) do 
            create :accreditation, trait,
              campus_ipeds_unitid: crosswalk_approved_public.cross
          end

          before(:each) do
            DataCsv.update_with_accreditation
          end

          it "leaves the data_csv.caution_flag as it was" do
            expect(data).not_to be_nil
            expect(data.caution_flag_reason).to be_nil
          end
        end 
      end
    end
  end

  #############################################################################
  ## update_with_arf_gibill
  #############################################################################
  describe "update_with_arf_gibill" do
    let!(:arf_gibill) do 
      create :arf_gibill, 
        facility_code: crosswalk_approved_public.facility_code
    end

    let(:data) { DataCsv.find_by(facility_code: arf_gibill.facility_code) }

    before(:each) do
      DataCsv.update_with_arf_gibill
    end

    describe "when matching" do
      it "matches cross to approved schools in data_csv" do
        expect(data).not_to be_nil
      end
    end

    describe "when copying fields to data_csv" do      
      ArfGibill::USE_COLUMNS.each do |column|
        it "updates the #{column} column" do
          expect(data[column]).to eq(arf_gibill[column])
        end
      end
    end
  end

  #############################################################################
  ## update_with_p911_tf
  #############################################################################
  describe "update_with_p911_tf" do
    let!(:p911_tf) do 
      create :p911_tf, 
        facility_code: crosswalk_approved_public.facility_code 
    end

    let(:data) { DataCsv.find_by(facility_code: p911_tf.facility_code) }

    before(:each) do
      DataCsv.update_with_p911_tf
    end

    describe "when matching" do
      it "is matched by facility_code" do
        expect(data).not_to be_nil
      end
    end

    describe "when copying fields to data_csv" do      
      P911Tf::USE_COLUMNS.each do |column|
        it "updates the #{column} column" do
          expect(data[column]).to eq(p911_tf[column])
        end
      end
    end
  end

  #############################################################################
  ## update_with_p911_yr
  #############################################################################
  describe "with p911_yrs" do
    let!(:p911_yr) { 
      create :p911_yr, 
        facility_code: crosswalk_approved_public.facility_code 
    }

    let(:data) { DataCsv.find_by(facility_code: p911_yr.facility_code) }

    before(:each) do
      DataCsv.update_with_p911_yr
    end

    describe "when matching" do
      it "is matched by facility_code" do
        expect(data).not_to be_nil
      end
    end

    describe "when copying fields to data_csv" do      
      P911Yr::USE_COLUMNS.each do |column|
        it "updates the #{column} column" do
          expect(data[column]).to eq(p911_yr[column])
        end
      end
    end
  end

  #############################################################################
  ## update_with_mou
  #############################################################################
  describe "update_with_mou" do
    let(:data) { DataCsv.find_by(ope6: mou.ope6) }

    describe "when matching" do
      let!(:mou) { create :mou, ope: crosswalk_approved_public.ope }

      before(:each) do
        DataCsv.update_with_mou
      end

      it "is matched by ope6" do
        expect(data).not_to be_nil
      end
    end

    describe "when copying fields to data_csv" do      
      let!(:mou) { create :mou, ope: crosswalk_approved_public.ope }

      let(:data) { DataCsv.find_by(ope6: mou.ope6) }

      before(:each) do
        DataCsv.update_with_mou
      end

      Mou::USE_COLUMNS.each do |column|
        it "updates the #{column} column" do
          expect(data[column]).to eq(mou[column])
        end
      end
    end

    describe "setting data_csv.caution_flag" do
      context "when dod_status is true" do
        let!(:mou) do 
          create :mou, :mou_probation, ope: crosswalk_approved_public.ope
        end

        let(:data) { DataCsv.find_by(ope6: mou.ope6) }

        before(:each) do
          DataCsv.update_with_mou
        end

        it "sets the data_csv.caution_flag true " do
          expect(data.caution_flag).to be_truthy
        end
      end

      context "when dod_status is false" do
        let!(:mou) do 
          create :mou, status: "blah", ope: crosswalk_approved_public.ope
        end

        let(:data) { DataCsv.find_by(ope6: mou.ope6) }

        before(:each) do
          DataCsv.update_with_mou
        end

        it "leaves the data.csv_flag alone" do
          expect(data.caution_flag).to be_nil
        end
      end
    end

    describe "setting the data_csv.caution_flag_reason" do
      let(:prior_reason) { 'some other reason,' }
      let(:reason) { 'dod probation For military tuition assistance,' }

      context "with dod_status equal to true" do
        let!(:mou) do 
          create :mou, :mou_probation, ope: crosswalk_approved_public.ope
        end

        let(:data) { DataCsv.find_by(ope6: mou.ope6) }

        before(:each) do
          DataCsv.find_by(ope6: mou.ope6)
            .update(caution_flag_reason: prior_reason)

          DataCsv.update_with_mou
        end

        it "appends data_csv.caution_flag_reason with its reason" do
          expect(data.caution_flag_reason).to eq("#{prior_reason}#{reason}")
        end          
      end

      context "with dod_status not equal to true" do
        let!(:mou) do 
          create :mou, status: 'blah', ope: crosswalk_approved_public.ope
        end

        let(:data) { DataCsv.find_by(ope6: mou.ope6) }

        before(:each) do
          DataCsv.find_by(ope6: mou.ope6)
            .update(caution_flag_reason: prior_reason)

          DataCsv.update_with_mou
        end

        it "appends data_csv.caution_flag_reason with its reason" do
          expect(data.caution_flag_reason).to eq(prior_reason)
        end          
      end

      context "with a repeated dod status" do
        let!(:mou) do 
          create :mou, status: 'blah', ope: crosswalk_approved_public.ope
        end

        let(:data) { DataCsv.find_by(ope6: mou.ope6) }

        before(:each) do
          DataCsv.find_by(ope6: mou.ope6).update(caution_flag_reason: reason)
          DataCsv.update_with_mou
        end

        it "appends data_csv.caution_flag_reason with its reason" do
          expect(data.caution_flag_reason).not_to eq(reason + reason)
          expect(data.caution_flag_reason).to eq(reason)
        end          
      end
    end
  end

  #############################################################################
  ## update_with_scorecard
  #############################################################################
  describe "update_with_scorecard" do
    let!(:scorecard) do 
      create :scorecard, 
        ope: crosswalk_approved_public.ope, 
        cross: crosswalk_approved_public.cross 
    end

    let(:data) { DataCsv.find_by(cross: scorecard.cross) }

    before(:each) do
      DataCsv.update_with_scorecard
    end

    describe "when matching" do
      it "is matched by cross" do
        expect(data).not_to be_nil
      end
    end

    describe "when copying fields to data_csv" do      
      Scorecard::USE_COLUMNS.each do |column|
        it "updates the #{column} column" do
          expect(data[column]).to eq(scorecard[column])
        end
      end
    end
  end

  #############################################################################
  ## update_with_ipeds_ic
  #############################################################################
  describe "update_with_ipeds_ic" do
    let!(:ipeds_ic) do
      create :ipeds_ic, cross: crosswalk_approved_public.cross
    end

    let(:data) { DataCsv.find_by(cross: ipeds_ic.cross) }

    before(:each) do
      DataCsv.update_with_ipeds_ic
    end

    describe "when matching" do
      it "is matched by cross" do
        expect(data).not_to be_nil
      end
    end

    describe "when copying fields to data_csv" do      
      IpedsIc::USE_COLUMNS.each do |column|
        it "updates the #{column} column" do
          expect(data[column]).to eq(ipeds_ic[column])
        end
      end
    end
  end

  #############################################################################
  ## update_with_ipeds_hd
  #############################################################################
  describe "update_with_ipeds_hd" do
    let!(:ipeds_hd) do
      create :ipeds_hd, cross: crosswalk_approved_public.cross
    end

    let(:data) { DataCsv.find_by(cross: ipeds_hd.cross) }

    before(:each) do
      DataCsv.update_with_ipeds_hd
    end

    describe "when matching" do
      it "is matched by cross" do
        expect(data).not_to be_nil
      end
    end

    describe "when copying fields to data_csv" do      
      IpedsHd::USE_COLUMNS.each do |column|
        it "updates the #{column} column" do
          expect(data[column]).to eq(ipeds_hd[column])
        end
      end
    end
  end

  #############################################################################
  ## update_with_ipeds_ic_ay
  #############################################################################
  describe "update_with_ipeds_ic_ay" do
    let!(:ipeds_ic_ay) do 
      create :ipeds_ic_ay, cross: crosswalk_approved_public.cross
    end

    let(:data) { DataCsv.find_by(cross: ipeds_ic_ay.cross) }

    before(:each) do
      DataCsv.update_with_ipeds_ic_ay
    end

    describe "when matching" do
      it "is matched by cross" do
        expect(data).not_to be_nil
      end
    end

    describe "when copying fields to data_csv" do      
      IpedsIcAy::USE_COLUMNS.each do |column|
        it "updates the #{column} column" do
          expect(data[column]).to eq(ipeds_ic_ay[column])
        end
      end
    end
  end

  #############################################################################
  ## update_with_ipeds_ic_py
  #############################################################################
  describe "update_with_ipeds_ic_py" do
    let!(:ipeds_ic_py) do 
      create :ipeds_ic_py, cross: crosswalk_approved_public.cross
    end

    let(:data) { DataCsv.find_by(cross: ipeds_ic_py.cross) }

    describe "when matching" do
      before(:each) do
        DataCsv.update_with_ipeds_ic_py
      end

      it "is matched by cross" do
        expect(data).not_to be_nil
      end
    end

    describe "when copying fields to data_csv" do   
      context "and the values in data_csv are nil" do
        before(:each) do
          DataCsv.update_with_ipeds_ic_py
        end

        IpedsIcPy::USE_COLUMNS.each do |column|
          it "updates the #{column} column" do
            expect(data[column]).to eq(ipeds_ic_py[column])
          end
        end
      end

      context "and the values in data_csv are not nil" do
        before(:each) do
          data.update(
            tuition_in_state: ipeds_ic_py.tuition_in_state - 1,
            tuition_out_of_state: ipeds_ic_py.tuition_out_of_state - 1,
            books: ipeds_ic_py.books - 1
          )

          DataCsv.update_with_ipeds_ic_py
        end

        IpedsIcPy::USE_COLUMNS.each do |column|
          it "does not update the #{column} column" do
            expect(data[column]).not_to eq(ipeds_ic_py[column])
          end
        end
      end
    end
  end

  #############################################################################
  ## update_with_sec702_school
  #############################################################################
  describe "update_with_sec702_school" do
    describe "when matching" do
      let!(:sec702_school) do
        create :sec702_school, sec_702: 'yes',
          facility_code: crosswalk_approved_public.facility_code
      end

      let(:data) do 
        DataCsv.find_by(facility_code: sec702_school.facility_code) 
      end

      before(:each) do
        DataCsv.update_with_sec702_school
      end

      it "is matched by facility_code" do
         expect(data).not_to be_nil
      end
    end

    describe "when copying fields to data_csv" do   
      context "for a public school" do
        context "with sec_702 equal to true" do
          let!(:sec702_school) do
            create :sec702_school, sec_702: 'yes',
              facility_code: crosswalk_approved_public.facility_code
          end

          let(:data) do 
            DataCsv.find_by(facility_code: sec702_school.facility_code) 
          end

          before(:each) do
            DataCsv.update_with_sec702_school
          end

          Sec702School::USE_COLUMNS.each do |column|
            it "updates the #{column} column" do
              expect(data[column]).to eq(sec702_school[column])
            end
          end
        end

        context "with sec_702 equal to nil" do
          let!(:sec702_school) do
            create :sec702_school, sec_702: nil,
              facility_code: crosswalk_approved_public.facility_code
          end

          let(:data) do 
            DataCsv.find_by(facility_code: sec702_school.facility_code) 
          end

          before(:each) do
            DataCsv.update_with_sec702_school
          end

          Sec702School::USE_COLUMNS.each do |column|
            it "does not update the #{column} column" do
              expect(data[column]).to be_nil
            end
          end
        end
      end

      context "for a non-public school" do
        let!(:sec702_school) do
          create :sec702_school, sec_702: 'no',
            facility_code: crosswalk_approved_private.facility_code
        end

        let(:data) do 
          DataCsv.find_by(facility_code: sec702_school.facility_code) 
        end

        before(:each) do
          DataCsv.update_with_sec702_school
        end

        Sec702School::USE_COLUMNS.each do |column|
          it "does not update the #{column} column" do
            expect(data[column]).to be_nil
          end
        end
      end
    end

    describe "setting the data_csv.caution_flag" do
      context "for a public school" do
        context "with sec_702 equal to true" do
          let!(:sec702_school) do
            create :sec702_school, sec_702: 'yes',
              facility_code: crosswalk_approved_public.facility_code
          end

          let(:data) do 
            DataCsv.find_by(facility_code: sec702_school.facility_code) 
          end

          before(:each) do
            DataCsv.update_with_sec702_school
          end

          it "does not set the caution_flag" do
            expect(data.caution_flag).to be_nil
          end          
        end

        context "with sec_702 equal to false" do
          let!(:sec702_school) do
            create :sec702_school, sec_702: 'no',
              facility_code: crosswalk_approved_public.facility_code
          end

          let(:data) do 
            DataCsv.find_by(facility_code: sec702_school.facility_code) 
          end

          before(:each) do
            DataCsv.update_with_sec702_school
          end

          it "sets the caution_flag" do
            expect(data.caution_flag).to be_truthy
          end          
        end        
      end

      context "for a non-public school" do
        let!(:sec702_school) do
          create :sec702_school, sec_702: 'no',
            facility_code: crosswalk_approved_private.facility_code
        end

        let(:data) do 
          DataCsv.find_by(facility_code: sec702_school.facility_code) 
        end

        before(:each) do
          DataCsv.update_with_sec702_school
        end

        it "does not set the caution_flag" do
          expect(data.caution_flag).to be_nil
        end  
      end
    end

    describe "setting the data_csv.caution_flag_reason" do
      let(:prior_reason) { 'some other reason,' }
      let(:reason) { 'does not offer required in-state tuition rates,' }

      context "for a public school" do
        context "with sec_702 equal to true" do
          let!(:sec702_school) do
            create :sec702_school, sec_702: 'yes',
              facility_code: crosswalk_approved_public.facility_code
          end

          let(:data) do 
            DataCsv.find_by(facility_code: sec702_school.facility_code) 
          end

          before(:each) do
            DataCsv.find_by(facility_code: sec702_school.facility_code)
              .update(caution_flag_reason: prior_reason)

            DataCsv.update_with_sec702_school
          end

          it "does not append data_csv.caution_flag_reason" do
            expect(data.caution_flag_reason).to eq(prior_reason)
          end          
        end

        context "with sec_702 nil" do
          let!(:sec702_school) do
            create :sec702_school, sec_702: nil,
              facility_code: crosswalk_approved_public.facility_code
          end

          let(:data) do 
            DataCsv.find_by(facility_code: sec702_school.facility_code) 
          end

          before(:each) do
            DataCsv.find_by(facility_code: sec702_school.facility_code)
              .update(caution_flag_reason: prior_reason)

            DataCsv.update_with_sec702_school
          end

          it "does not append data_csv.caution_flag_reason" do
            expect(data.caution_flag_reason).to eq(prior_reason)
          end          
        end

        context "with sec_702 equal to false" do
          context "and this reason is not yet in the flag" do
            let!(:sec702_school) do
              create :sec702_school, sec_702: 'no',
                facility_code: crosswalk_approved_public.facility_code
            end

            let(:data) do 
              DataCsv.find_by(facility_code: sec702_school.facility_code) 
            end

            before(:each) do
              DataCsv.find_by(facility_code: sec702_school.facility_code)
                .update(caution_flag_reason: prior_reason)

              DataCsv.update_with_sec702_school
            end

            it "appends data_csv.caution_flag_reason" do
              expect(data.caution_flag_reason).to eq(prior_reason + reason)
            end  
          end

          context "and this reason is already in the flag (from sec702)" do
            let!(:sec702_school) do
              create :sec702_school, sec_702: 'no',
                facility_code: crosswalk_approved_public.facility_code
            end

            let(:data) do 
              DataCsv.find_by(facility_code: sec702_school.facility_code) 
            end

            before(:each) do
              DataCsv.find_by(facility_code: sec702_school.facility_code)
                .update(caution_flag_reason: reason)

              DataCsv.update_with_sec702_school
            end

            it "appends data_csv.caution_flag_reason" do
              expect(data.caution_flag_reason).not_to eq(reason + reason)
              expect(data.caution_flag_reason).to eq(reason)
            end  
          end 
        end
      end

      context "for a non-public school" do
        let!(:sec702_school) do
          create :sec702_school, sec_702: 'no',
            facility_code: crosswalk_approved_private.facility_code
        end

        let(:data) do 
          DataCsv.find_by(facility_code: sec702_school.facility_code) 
        end

        before(:each) do
          DataCsv.find_by(facility_code: sec702_school.facility_code)
            .update(caution_flag_reason: prior_reason)

          DataCsv.update_with_sec702_school
        end

        it "does not append data_csv.caution_flag_reason" do
          expect(data.caution_flag_reason).to eq(prior_reason)
        end   
      end
    end
  end

  #############################################################################
  ## update_with_sec702
  #############################################################################
  describe "update_with_sec702" do
    describe "when matching" do
      let!(:sec702) do
        create :sec702, sec_702: 'yes', state: weam_approved_public.state
      end

      let(:data) do 
        DataCsv.find_by(state: sec702.state) 
      end

      before(:each) do
        DataCsv.update_with_sec702_school
      end

      it "is matched by facility_code" do
         expect(data).not_to be_nil
      end
    end

    describe "when copying fields to data_csv" do   
      context "for a public school" do
        context "with sec_702 equal to true" do
          let!(:sec702) do
            create :sec702, sec_702: 'yes', state: weam_approved_public.state
          end

          let(:data) do 
            DataCsv.find_by(state: sec702.state) 
          end

          before(:each) do
            DataCsv.update_with_sec702
          end

          Sec702::USE_COLUMNS.each do |column|
            it "updates the #{column} column" do
              expect(data[column]).to eq(sec702[column])
            end
          end
        end

        context "with sec_702 equal to nil" do
          let!(:sec702) do
            create :sec702, sec_702: nil, state: weam_approved_public.state
          end

          let(:data) do 
            DataCsv.find_by(state: sec702.state) 
          end

          before(:each) do
            DataCsv.update_with_sec702
          end

          Sec702::USE_COLUMNS.each do |column|
            it "does not update the #{column} column" do
              expect(data[column]).to be_nil
            end
          end
        end
      end

      context "for a non-public school" do
        let!(:sec702) do
          create :sec702, sec_702: 'no', state: weam_approved_private.state
        end

        let(:data) do 
          DataCsv.find_by(state: sec702.state) 
        end

        before(:each) do
          DataCsv.update_with_sec702
        end

        Sec702::USE_COLUMNS.each do |column|
          it "does not update the #{column} column" do
            expect(data[column]).to be_nil
          end
        end
      end
    end

    describe "setting the data_csv.caution_flag" do
      context "for a public school" do
        context "with sec_702 equal to true" do
          let!(:sec702) do
            create :sec702, sec_702: 'yes', state: weam_approved_public.state
          end

          let(:data) do 
            DataCsv.find_by(state: sec702.state) 
          end

          before(:each) do
            DataCsv.update_with_sec702
          end

          it "does not set the caution_flag if sec_702 is true" do
            expect(data.caution_flag).to be_nil
          end          
        end

        context "with sec_702 equal to false" do
          context "and data_csv.caution_flag equal to nil" do
            let!(:sec702) do
              create :sec702, sec_702: 'no', state: weam_approved_public.state
            end

            let(:data) do 
              DataCsv.find_by(state: sec702.state) 
            end

            before(:each) do
              DataCsv.update_with_sec702
            end

            it "sets the caution_flag if sec_702 is false" do
              expect(data.caution_flag).to be_truthy
            end          
          end 

          context "and data_csv.caution_flag not equal to nil" do
            let!(:sec702) do
              create :sec702, sec_702: 'no', state: weam_approved_public.state
            end

            let(:data) do 
              DataCsv.find_by(state: sec702.state)
                .update(caution_flag: false)

              DataCsv.find_by(state: sec702.state) 
            end

            before(:each) do
              DataCsv.update_with_sec702
            end

            it "does not set the caution_flag if sec_702 is true" do
              expect(data.caution_flag).not_to be_nil
            end          
          end 
        end    
      end

      context "for a non-public school" do
        let!(:sec702) do
          create :sec702, sec_702: 'yes', state: weam_approved_private.state
        end

        let(:data) do 
          DataCsv.find_by(state: sec702.state) 
        end

        before(:each) do
          DataCsv.update_with_sec702
        end

        it "does not set the caution_flag" do
          expect(data).not_to be_nil
          expect(data.caution_flag).to be_nil
        end  
      end
    end

    describe "setting the data_csv.caution_flag_reason" do
      let(:prior_reason) { 'some other reason,' }
      let(:reason) { 'does not offer required in-state tuition rates,' }

      context "for a public school" do
        context "with sec_702 equal to true" do
          let!(:sec702) do
            create :sec702, sec_702: 'yes', state: weam_approved_public.state
          end

          let(:data) do 
            DataCsv.find_by(state: sec702.state) 
          end

          before(:each) do
            DataCsv.find_by(state: sec702.state)
              .update(caution_flag_reason: prior_reason)

            DataCsv.update_with_sec702
          end

          it "does not append data_csv.caution_flag_reason" do
            expect(data).not_to be_nil
            expect(data.caution_flag_reason).to eq(prior_reason)
          end          
        end

        context "with sec_702 nil" do
          let!(:sec702) do
            create :sec702, sec_702: 'yes', state: weam_approved_public.state
          end

          let(:data) do 
            DataCsv.find_by(state: sec702.state) 
          end

          before(:each) do
            DataCsv.find_by(state: sec702.state)
              .update(caution_flag_reason: prior_reason)

            DataCsv.update_with_sec702
          end

          it "does not append data_csv.caution_flag_reason" do
            expect(data).not_to be_nil
            expect(data.caution_flag_reason).to eq(prior_reason)
          end          
        end

        context "with sec_702 equal to false" do
          context "and this reason is not yet in the flag" do
            let!(:sec702) do
              create :sec702, sec_702: 'no', state: weam_approved_public.state
            end

            let(:data) do 
              DataCsv.find_by(state: sec702.state) 
            end

            before(:each) do
              DataCsv.find_by(state: sec702.state)
                .update(caution_flag_reason: prior_reason)

              DataCsv.update_with_sec702
            end

            it "appends data_csv.caution_flag_reason" do
              expect(data.caution_flag_reason).to eq(prior_reason + reason)
            end  
          end

          context "and this reason is already in the flag (from sec702)" do
            let!(:sec702) do
              create :sec702, sec_702: 'no', state: weam_approved_public.state
            end

            let(:data) do 
              DataCsv.find_by(state: sec702.state) 
            end

            before(:each) do
              DataCsv.find_by(state: sec702.state)
                .update(caution_flag_reason: reason)

              DataCsv.update_with_sec702
            end

            it "appends data_csv.caution_flag_reason" do
              expect(data.caution_flag_reason).not_to eq(reason + reason)
              expect(data.caution_flag_reason).to eq(reason)
            end  
          end 
        end
      end

      context "for a non-public school" do
        let!(:sec702) do
          create :sec702, sec_702: 'no', state: weam_approved_private.state
        end

        let(:data) do 
          DataCsv.find_by(state: sec702.state) 
        end

        before(:each) do
          DataCsv.find_by(state: sec702.state)
            .update(caution_flag_reason: prior_reason)

          DataCsv.update_with_sec702
        end

        it "does not append data_csv.caution_flag_reason" do
          expect(data.caution_flag_reason).to eq(prior_reason)
        end   
      end
    end
  end

  #############################################################################
  ## update_with_settlement
  #############################################################################
  describe "update_with_settlement" do
    describe "when matching" do
      let!(:settlement) do
        create :settlement, cross: crosswalk_approved_public.cross
      end

      let(:data) do 
        DataCsv.find_by(cross: settlement.cross) 
      end

      before(:each) do
        DataCsv.update_with_settlement
      end

      it "is matched by cross" do
         expect(data).not_to be_nil
      end
    end

    describe "setting the data_csv.caution_flag_reason" do
      let(:prior_reason) { 'some other reason,' }

      context "with settlement_description not equal to nil" do
        let!(:settlement) do
          create :settlement, cross: crosswalk_approved_public.cross
        end

        let(:data) do 
          DataCsv.find_by(cross: settlement.cross) 
        end

        before(:each) do
          DataCsv.find_by(cross: settlement.cross)
            .update(caution_flag_reason: prior_reason)

          DataCsv.update_with_settlement
        end

        it "appends data_csv.caution_flag_reason with its reason" do
          new_reason = "#{prior_reason}#{settlement.settlement_description},"
          expect(data.caution_flag_reason).to eq(new_reason)
        end          
      end

      context "with a repeated settlement_description" do
        let!(:settlement) do
          create :settlement, cross: crosswalk_approved_public.cross
        end

        let(:data) do 
          DataCsv.find_by(cross: settlement.cross) 
        end

        let(:reason) { "#{settlement.settlement_description}," }


        before(:each) do
          DataCsv.find_by(cross: settlement.cross)
            .update(caution_flag_reason: reason)

          DataCsv.update_with_settlement
        end

        it "does not append data_csv.caution_flag_reason with the same reason" do
          expect(data.caution_flag_reason).not_to eq(reason + reason)
          expect(data.caution_flag_reason).to eq(reason)
        end          
      end
    end
  end

  #############################################################################
  ## update_with_hcm
  #############################################################################
  describe "update_with_hcm" do
    describe "when matching" do
      let!(:hcm) do
        create :hcm, ope: crosswalk_approved_public.ope
      end

      let(:data) do 
        DataCsv.find_by(ope6: hcm.ope6) 
      end

      before(:each) do
        DataCsv.update_with_hcm
      end

      it "is matched by cross" do
         expect(data).not_to be_nil
      end
    end

    describe "setting the data_csv.caution_flag" do
      let!(:hcm) do
        create :hcm, ope: crosswalk_approved_public.ope
      end

      let(:data) do 
        DataCsv.find_by(ope6: hcm.ope6) 
      end

      before(:each) do
        DataCsv.update_with_hcm
      end

      it "with an hcm_reason" do
        expect(data.caution_flag).to be_truthy
      end          
    end

    describe "setting the data_csv.caution_flag_reason" do
      let(:prior_reason) { 'some other reason,' }
      let(:reason) { "heightened cash monitoring (#{hcm.hcm_reason})," }

      context "with a non-nil hcm_reason" do
        let!(:hcm) do
          create :hcm, ope: crosswalk_approved_public.ope
        end

        let(:data) do 
          DataCsv.find_by(ope6: hcm.ope6) 
        end

        before(:each) do
          DataCsv.find_by(ope6: hcm.ope6)
            .update(caution_flag_reason: prior_reason)

          DataCsv.update_with_hcm
        end

        it "appends data_csv.caution_flag_reason with its reason" do
          expect(data.caution_flag_reason).to eq("#{prior_reason}#{reason}")
        end  
      end

      context "with a repeated hcm_reason" do
        let!(:hcm) do
          create :hcm, ope: crosswalk_approved_public.ope
        end

        let(:data) do 
          DataCsv.find_by(ope6: hcm.ope6) 
        end

        before(:each) do
          DataCsv.find_by(ope6: hcm.ope6)
            .update(caution_flag_reason: reason)

          DataCsv.update_with_hcm
        end

        it "dues not append data_csv.caution_flag_reason with the same reason" do
          expect(data.caution_flag_reason).not_to eq(reason + reason)
          expect(data.caution_flag_reason).to eq(reason)
        end  
      end
    end
  end

  #############################################################################
  ## update_with_complaint
  #############################################################################
  describe "update_with_complaint" do
    let(:data) { DataCsv.find_by(facility_code: @complaint.facility_code) }

    before(:each) do
      create :complaint, :all_issues,
        facility_code: crosswalk_approved_public.facility_code 

      Complaint.update_sums_by_fac
      Complaint.update_sums_by_ope6

      @complaint = Complaint.find_by(facility_code: crosswalk_approved_public.facility_code)

      DataCsv.initialize_with_weams
      DataCsv.update_with_complaint
    end

    describe "when matching" do
      it "is matched by facility_code" do
        expect(data).not_to be_nil
      end
    end

    describe "when copying fields to data_csv" do      
      Complaint::USE_COLUMNS.each do |column|
        it "updates the #{column} column" do
          expect(data[column]).to eq(@complaint[column])
        end
      end
    end
  end
end

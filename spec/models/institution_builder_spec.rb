# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionBuilder, type: :model do
  let(:user) { User.first }
  let(:institutions) { Institution.version(Version.current_preview.number) }

  before(:each) do
    create :user, email: 'fred@va.gov', password: 'fuggedabodit'
  end

  describe '#run' do
    before(:each) do
      create :weam, :institution_builder
      create :crosswalk, :institution_builder
    end

    context 'when successful' do
      it 'returns a success = true' do
        expect(InstitutionBuilder.run(user)[:success]).to be_truthy
      end

      it 'returns the new preview version record if sucessful' do
        create :version
        old_version = Version.current_preview

        version = InstitutionBuilder.run(user)[:version]

        expect(version).to eq(Version.current_preview)
        expect(version).not_to eq(old_version)
        expect(version.production).to be_falsey
      end

      it 'returns a nil error_msg if sucessful' do
        expect(InstitutionBuilder.run(user)[:error_msg]).to be_nil
      end

      it 'returns a success notice when successful' do
        expect(InstitutionBuilder.run(user)[:notice]).to eq('Institution build was successful')
      end
    end

    context 'when not successful' do
      it 'returns a success = false' do
        allow(InstitutionBuilder).to receive(:add_crosswalk).and_raise(StandardError, 'BOOM!')
        expect(InstitutionBuilder.run(user)[:success]).to be_falsey
      end

      it 'returns an error message' do
        allow(InstitutionBuilder).to receive(:add_crosswalk).and_raise(StandardError, 'BOOM!')
        expect(InstitutionBuilder.run(user)[:error_msg]).to eq('BOOM!')
      end

      it 'logs errors at the database level' do
        pg_result = double('PG::Result Double', error_message: 'BOOM!')
        pg_error = double('PG::Error Double', result: pg_result)

        statement_invalid = ActiveRecord::StatementInvalid.new('message', pg_error)
        statement_invalid.set_backtrace(%(backtrace))

        allow(InstitutionBuilder).to receive(:add_crosswalk).and_raise(statement_invalid)
        expect(Rails.logger).to receive(:error).with('There was an error occurring at the database level: BOOM!')
        InstitutionBuilder.run(user)
      end

      it 'logs errors at the Rails level' do
        allow(InstitutionBuilder).to receive(:add_crosswalk).and_raise(StandardError, 'BOOM!')

        expect(Rails.logger).to receive(:error).with('There was an error of unexpected origin: BOOM!')
        InstitutionBuilder.run(user)
      end

      it 'does not change the institutions or versions if not successful' do
        allow(InstitutionBuilder).to receive(:add_crosswalk).and_raise(StandardError, 'BOOM!')
        create :version
        version = Version.current_preview

        InstitutionBuilder.run(user)
        expect(Institution.count).to be_zero
        expect(Version.current_preview).to eq(version)
      end
    end

    describe 'when initializing with Weam data' do
      let(:weam) { Weam.first }
      let(:institution) { institutions.first }

      before(:each) do
        InstitutionBuilder.run(user)
      end

      it 'adds approved schools only' do
        expect(institutions.count).to eq(1)
        expect(institution.facility_code).to eq(weam.facility_code)
      end

      it 'copies columns used by institutions' do
        Weam::COLS_USED_IN_INSTITUTION.each do |column|
          expect(weam[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding Crosswalk data' do
      let(:institution) { institutions.find_by(facility_code: crosswalk.facility_code) }
      let(:crosswalk) { Crosswalk.first }

      before(:each) do
        InstitutionBuilder.run(user)
      end

      it 'copies columns used by institutions' do
        Crosswalk::COLS_USED_IN_INSTITUTION.each do |column|
          expect(crosswalk[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding Sva data' do
      let(:institution) { institutions.find_by(cross: sva.cross) }
      let(:sva) { Sva.first }

      before(:each) do
        create :sva, :institution_builder
        InstitutionBuilder.run(user)
      end

      it 'copies columns used by institutions' do
        expect(institution.student_veteran_link).to eq(sva.student_veteran_link)
      end

      it 'sets student_veteran to TRUE for every sva record' do
        expect(institution.student_veteran).to be_truthy
      end
    end

    describe 'when adding Vsoc data' do
      let(:institution) { institutions.find_by(facility_code: vsoc.facility_code) }
      let(:vsoc) { Vsoc.first }

      before(:each) do
        create :vsoc, :institution_builder
        InstitutionBuilder.run(user)
      end

      it 'copies columns used by institutions' do
        Vsoc::COLS_USED_IN_INSTITUTION.each do |column|
          expect(vsoc[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding EightKey data' do
      let(:institution) { institutions.find_by(cross: eight_key.cross) }
      let(:eight_key) { EightKey.first }

      before(:each) do
        create :eight_key, :institution_builder
        InstitutionBuilder.run(user)
      end

      it 'sets eight_keys to TRUE for every eight_key record' do
        expect(institution.eight_keys).to be_truthy
      end
    end

    describe 'when adding Accreditation data' do
      let(:institution) { institutions.find_by(cross: accreditation.cross) }
      let(:accreditation) { Accreditation.first }

      describe 'with regards to the time frame' do
        it 'only adds current accreditations' do
          create :accreditation, :institution_builder, periods: '12/12/2012 - current'
          InstitutionBuilder.run(user)

          expect(institution.accreditation_type).not_to be_nil
        end

        it 'does not add non-current accreditations' do
          create :accreditation, :institution_builder, periods: 'Expired accreditation'
          InstitutionBuilder.run(user)

          expect(institution.accreditation_type).to be_nil
        end
      end

      describe 'with regards to the accrediting authority' do
        it 'adds non-institutional accreditations' do
          create :accreditation, :institution_builder, csv_accreditation_type: 'institutional'
          InstitutionBuilder.run(user)

          expect(institution.accreditation_type).not_to be_nil
        end

        it 'does not add non-institutional accreditations' do
          create :accreditation, :institution_builder, csv_accreditation_type: 'specialized'
          InstitutionBuilder.run(user)

          expect(institution.accreditation_type).to be_nil
        end
      end

      describe 'the accreditation_type' do
        Accreditation::ACCREDITATIONS.each_pair do |type, agency_regex_array|
          agency_regex_array.map(&:source).each do |agency_name|
            it "is set to #{type} when the agency name contains '#{agency_name}'" do
              create :accreditation, :institution_builder, agency_name: 'Agency ' + agency_name
              InstitutionBuilder.run(user)

              expect(institution.accreditation_type).to eq(type)
            end
          end
        end

        it 'prefers national over hybrid' do
          create :accreditation, :institution_builder, agency_name: 'Biblical School'
          create :accreditation, :institution_builder, agency_name: 'Design School'
          InstitutionBuilder.run(user)

          expect(institution.accreditation_type).to eq('national')
        end

        it 'prefers regional over hybrid and national' do
          create :accreditation, :institution_builder, agency_name: 'Biblical School'
          create :accreditation, :institution_builder, agency_name: 'Middle School'
          create :accreditation, :institution_builder, agency_name: 'Design School'
          InstitutionBuilder.run(user)

          expect(institution.accreditation_type).to eq('regional')
        end
      end

      describe 'the accreditation status' do
        it "is set only for 'Probation' and 'Show Cause'" do
          create :accreditation, :institution_builder, accreditation_status: 'Expired'
          InstitutionBuilder.run(user)

          expect(institution.accreditation_status).to be_nil
        end

        ['Probation', 'Show Cause'].each do |status|
          it "is set for #{status}" do
            create :accreditation, :institution_builder, accreditation_status: status
            InstitutionBuilder.run(user)

            expect(institution.accreditation_status).to eq(status)
          end
        end

        it "prefers 'Show Cause' over 'Probation' for the same accreditation type" do
          create :accreditation, :institution_builder, accreditation_status: 'Show Cause'
          create :accreditation, :institution_builder, accreditation_status: 'Probation'
          InstitutionBuilder.run(user)

          expect(institution.accreditation_status).to eq('Show Cause')
        end

        it 'only uses the accreditation_status for the accreditation_type' do
          create :accreditation, :institution_builder, accreditation_status: 'Show Cause'
          create :accreditation, :institution_builder, accreditation_status: 'Probation', agency_name: 'Biblical'
          InstitutionBuilder.run(user)

          expect(institution.accreditation_status).to eq('Probation')
        end
      end

      describe 'the caution_flag' do
        it 'is set to true for any non-nil status' do
          create :accreditation, :institution_builder, accreditation_status: 'Expired'
          InstitutionBuilder.run(user)

          expect(institution.caution_flag).to be_truthy
        end

        it 'is set falsey for any nil status' do
          create :accreditation, :institution_builder, accreditation_status: nil
          InstitutionBuilder.run(user)

          expect(institution.caution_flag).to be_falsey
        end
      end

      describe 'the caution_flag_reason' do
        it 'concatenates multiple accreditation cautions' do
          create :accreditation, :institution_builder, accreditation_status: 'Show Cause'
          create :accreditation, :institution_builder, accreditation_status: 'Probation'
          create :accreditation, :institution_builder, accreditation_status: 'Expired'
          InstitutionBuilder.run(user)

          expect(
            institution.caution_flag_reason
          ).to match(/Show Cause/i).and match(/Probation/i).and match(/Expired/i)
        end

        it 'concatenates new reasons to the existing caution_flag_reason' do
          result = InstitutionBuilder.run(user)
          create :accreditation, :institution_builder, accreditation_status: 'Expired'
          Institution.find_by(cross: accreditation.cross).update(caution_flag_reason: 'blah-blah')
          InstitutionBuilder.add_accreditation(result[:version].number)

          expect(institution.caution_flag_reason).to eq('blah-blah, Accreditation (Expired)')
        end
      end
    end

    describe 'when adding ArfGiBill data' do
      let(:institution) { institutions.find_by(facility_code: arf_gi_bill.facility_code) }
      let(:arf_gi_bill) { ArfGiBill.first }

      before(:each) do
        create :arf_gi_bill, :institution_builder
        InstitutionBuilder.run(user)
      end

      it 'copies columns used by institutions' do
        expect(institution.gibill).to eq(arf_gi_bill.gibill)
      end
    end

    describe 'when adding P911Tf data' do
      let(:institution) { institutions.find_by(facility_code: p911_tf.facility_code) }
      let(:p911_tf) { P911Tf.first }

      before(:each) do
        create :p911_tf, :institution_builder
        InstitutionBuilder.run(user)
      end

      it 'copies columns used by institutions' do
        P911Tf::COLS_USED_IN_INSTITUTION.each do |column|
          expect(p911_tf[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding P911Yr data' do
      let(:institution) { institutions.find_by(facility_code: p911_yr.facility_code) }
      let(:p911_yr) { P911Yr.first }

      before(:each) do
        create :p911_yr, :institution_builder
        InstitutionBuilder.run(user)
      end

      it 'copies columns used by institutions' do
        P911Yr::COLS_USED_IN_INSTITUTION.each do |column|
          expect(p911_yr[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding Mou data' do
      let(:institution) { institutions.find_by(ope6: mou.ope6) }
      let(:reason) { 'DoD Probation For Military Tuition Assistance' }
      let(:mou) { Mou.first }

      ['PRoBATIon Dod', 'title IV NON-comPliant'].each do |status|
        it "sets dodmou TRUE for status '#{status}'" do
          create :mou, :institution_builder, status: status
          InstitutionBuilder.run(user)
        end
      end

      it 'copies columns used by institutions' do
        create :mou, :institution_builder
        InstitutionBuilder.run(user)

        expect(mou.dodmou).to eq(institution.dodmou)
      end

      describe 'the caution_flag' do
        it 'is sets when dod_status is true' do
          create :mou, :institution_builder
          InstitutionBuilder.run(user)

          expect(institution.caution_flag).to be_truthy
        end

        it 'is not set when dod_status is not true' do
          create :mou, :institution_builder, :by_title_iv
          InstitutionBuilder.run(user)

          expect(institution.caution_flag).to be_falsey
        end
      end

      describe 'the caution_flag_reason' do
        it 'is set when dod_status is true' do
          create :mou, :institution_builder
          InstitutionBuilder.run(user)

          expect(institution.caution_flag_reason).to eq(reason)
        end

        it 'contentates the existing reasons' do
          create :accreditation, :institution_builder, accreditation_status: 'Probation'
          create :mou, :institution_builder
          InstitutionBuilder.run(user)

          expect(institution.caution_flag_reason).to match(/Accreditation/).and match(/DoD Probation/)
        end

        it 'is unaltered when dod_status is not true' do
          create :accreditation, :institution_builder, accreditation_status: 'Probation'
          create :mou, :institution_builder, :by_title_iv

          InstitutionBuilder.run(user)

          expect(institution.caution_flag_reason).not_to match(/DoD/)
          expect(institution.caution_flag_reason).to match(/Accreditation/)
        end
      end
    end

    describe 'when adding Scorecard data' do
      let(:institution) { institutions.find_by(cross: scorecard.cross) }
      let(:scorecard) { Scorecard.first }

      before(:each) do
        create :scorecard, :institution_builder
        InstitutionBuilder.run(user)
      end

      it 'copies columns used by institutions' do
        Scorecard::COLS_USED_IN_INSTITUTION.each do |column|
          expect(scorecard[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding IpedsIc data' do
      let(:institution) { institutions.find_by(cross: ipeds_ic.cross) }
      let(:ipeds_ic) { IpedsIc.first }

      before(:each) do
        create :ipeds_ic, :institution_builder
        InstitutionBuilder.run(user)
      end

      it 'copies columns used by institutions' do
        IpedsIc::COLS_USED_IN_INSTITUTION.each do |column|
          expect(ipeds_ic[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding IpedsHd data' do
      let(:institution) { institutions.find_by(cross: ipeds_hd.cross) }
      let(:ipeds_hd) { IpedsHd.first }

      before(:each) do
        create :ipeds_hd, :institution_builder
        InstitutionBuilder.run(user)
      end

      it 'copies columns used by institutions' do
        IpedsHd::COLS_USED_IN_INSTITUTION.each do |column|
          expect(ipeds_hd[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding IpedsIcAy data' do
      let(:institution) { institutions.find_by(cross: ipeds_ic_ay.cross) }
      let(:ipeds_ic_ay) { IpedsIcAy.first }

      before(:each) do
        create :ipeds_ic_ay, :institution_builder
        InstitutionBuilder.run(user)
      end

      it 'copies columns used by institutions' do
        IpedsIcAy::COLS_USED_IN_INSTITUTION.each do |column|
          expect(ipeds_ic_ay[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding IpedsIcPy data' do
      let(:institution) { institutions.find_by(cross: ipeds_ic_py.cross) }
      let(:ipeds_ic_py) { IpedsIcPy.first }
      let(:ipeds_ic_ay) { IpedsIcAy.first }

      let(:nil_ipeds_ic_ay) { IpedsIcPy::COLS_USED_IN_INSTITUTION.each_with_object({}) { |v, o| o[v] = nil } }

      context 'and the institution fields are nil' do
        it 'copies columns used by institutions' do
          create :ipeds_ic_py, :institution_builder
          InstitutionBuilder.run(user)

          IpedsIcPy::COLS_USED_IN_INSTITUTION.each do |column|
            expect(ipeds_ic_py[column]).to eq(institution[column])
          end
        end
      end

      context 'and the institution fields are not nil' do
        it 'the institution record matches the ipeds_ic_ay record' do
          create :ipeds_ic_ay, :institution_builder
          create :ipeds_ic_py, :institution_builder
          InstitutionBuilder.run(user)

          IpedsIcPy::COLS_USED_IN_INSTITUTION.each do |column|
            expect(ipeds_ic_py[column]).not_to eq(institution[column])
          end

          IpedsIcAy::COLS_USED_IN_INSTITUTION.each do |column|
            expect(ipeds_ic_ay[column]).to eq(institution[column])
          end
        end
      end
    end

    describe 'when adding Sec702 and Sec702School data' do
      let(:sec702) { Sec702.first }
      let(:sec702_school) { Sec702School.first }

      context 'and the school is non-public' do
        it 'the institution is unaffected by Sec702School' do
          Weam.delete_all
          create :weam, :institution_builder, :private
          create :sec702_school, :institution_builder
          InstitutionBuilder.run(user)

          expect(institutions.first.sec_702).to be_nil
        end

        it 'the institution is unaffected by Sec702' do
          Weam.delete_all
          create :weam, :institution_builder, :private
          create :sec702, :institution_builder
          InstitutionBuilder.run(user)

          expect(institutions.first.sec_702).to be_nil
        end
      end

      context 'and the school is public' do
        describe 'sec_702' do
          it 'is set from Section702' do
            create :sec702, :institution_builder
            InstitutionBuilder.run(user)

            expect(institutions.first.sec_702).not_to be_nil
            expect(institutions.first.sec_702).to be_falsy
          end

          it 'is set from Section702School' do
            create :sec702_school, :institution_builder
            InstitutionBuilder.run(user)

            expect(institutions.first.sec_702).not_to be_nil
            expect(institutions.first.sec_702).to be_falsey
          end

          it 'prefers Sec702School over Section702' do
            create :weam, :institution_builder, :private
            create :sec702_school, :institution_builder, sec_702: true
            create :sec702, :institution_builder
            InstitutionBuilder.run(user)

            expect(institutions.first.sec_702).to be_truthy
          end
        end
      end

      describe 'the caution_flag' do
        it 'is set from Section702 when sec_702 is false' do
          create :sec702, :institution_builder
          InstitutionBuilder.run(user)

          expect(institutions.first.caution_flag).not_to be_nil
          expect(institutions.first.caution_flag).to be_truthy
        end

        it 'is set from Section702School when sec_702 is false' do
          create :sec702_school, :institution_builder
          InstitutionBuilder.run(user)

          expect(institutions.first.caution_flag).not_to be_nil
          expect(institutions.first.caution_flag).to be_truthy
        end

        it 'prefers Sec702School over Section702' do
          create :weam, :institution_builder, :private
          create :sec702_school, :institution_builder, sec_702: true
          create :sec702, :institution_builder
          InstitutionBuilder.run(user)

          expect(institutions.first.caution_flag).to be_falsey
        end
      end

      describe 'the caution_flag_reason' do
        let(:reason) { 'Does Not Offer Required In-State Tuition Rates' }

        it 'is set from Section702 when sec_702 is false' do
          create :sec702, :institution_builder
          InstitutionBuilder.run(user)

          expect(institutions.first.caution_flag_reason).not_to be_nil
          expect(institutions.first.caution_flag_reason).to eq(reason)
        end

        it 'is set from Section702School when sec_702 is false' do
          create :sec702_school, :institution_builder
          InstitutionBuilder.run(user)

          expect(institutions.first.caution_flag_reason).not_to be_nil
          expect(institutions.first.caution_flag_reason).to eq(reason)
        end

        it 'prefers Sec702School over Section702' do
          create :weam, :institution_builder, :private
          create :sec702_school, :institution_builder, sec_702: true
          create :sec702, :institution_builder
          InstitutionBuilder.run(user)

          expect(institutions.first.caution_flag_reason).to be_nil
        end

        it 'concatenates the sec_702 reason when sec_702 is false' do
          create :accreditation, :institution_builder, accreditation_status: 'Probation'
          create :sec702, :institution_builder
          InstitutionBuilder.run(user)

          expect(institutions.first.caution_flag_reason).to match(/Accreditation/).and match(/Tuition/)
        end

        it 'is left unaltered when sec_702 is true' do
          create :accreditation, :institution_builder, accreditation_status: 'Probation'
          create :sec702_school, :institution_builder, sec_702: true
          InstitutionBuilder.run(user)

          expect(institutions.first.caution_flag_reason).to match(/Accreditation/)
          expect(institutions.first.caution_flag_reason).not_to match(/Tuition/)
        end
      end
    end

    describe 'when adding Settlement data' do
      let(:institution) { institutions.find_by(cross: settlement.cross) }
      let(:settlement) { Settlement.first }

      describe 'the caution_flag' do
        it 'is set for every settlement' do
          create :settlement, :institution_builder
          InstitutionBuilder.run(user)

          expect(institution.caution_flag).to be_truthy
        end
      end

      describe 'the caution_flag_reason' do
        it 'is set to the settlement_description' do
          create :settlement, :institution_builder
          InstitutionBuilder.run(user)

          expect(institution.caution_flag_reason).to eq(settlement.settlement_description)
        end

        it 'is set with multiple descriptions' do
          create :settlement, :institution_builder
          create :settlement, :institution_builder, settlement_description: 'another description'
          InstitutionBuilder.run(user)

          expect(institution.caution_flag_reason).to match(settlement.settlement_description)
            .and match('another description')
        end

        it 'is concatenated with the settlement_description' do
          create :accreditation, :institution_builder, accreditation_status: 'Probation'
          create :settlement, :institution_builder
          InstitutionBuilder.run(user)

          expect(institutions.first.caution_flag_reason).to match(/Accreditation/)
            .and match(settlement.settlement_description)
        end
      end
    end

    describe 'when adding Hcm data' do
      let(:institution) { institutions.find_by(ope6: hcm.ope6) }
      let(:hcm) { Hcm.first }

      describe 'the caution_flag' do
        it 'is set for every heightened cash monitoring notice' do
          create :hcm, :institution_builder
          InstitutionBuilder.run(user)

          expect(institution.caution_flag).to be_truthy
        end
      end

      describe 'the caution_flag_reason' do
        it 'is set to the hcm_reason' do
          create :hcm, :institution_builder
          InstitutionBuilder.run(user)

          expect(institution.caution_flag_reason).to match(hcm.hcm_reason)
        end

        it 'is set with multiple hcm_reason' do
          create :hcm, :institution_builder
          create :hcm, :institution_builder, hcm_reason: 'another reason'
          InstitutionBuilder.run(user)

          expect(institution.caution_flag_reason).to match(Regexp.new(hcm.hcm_reason))
            .and match(/another reason/)
        end

        it 'is concatenated with the hcm_reason' do
          create :accreditation, :institution_builder, accreditation_status: 'Probation'
          create :hcm, :institution_builder
          InstitutionBuilder.run(user)

          expect(institutions.first.caution_flag_reason).to match(/Accreditation/)
            .and match(Regexp.new(hcm.hcm_reason))
        end
      end
    end

    describe 'when adding Complaint data' do
      let(:institution) { institutions.find_by(facility_code: complaint.facility_code) }
      let(:complaint) { Complaint.first }

      before(:each) do
        create_list :complaint, 2, :institution_builder, :all_issues
      end

      it 'calls update_ope_from_crosswalk' do
        expect(Complaint).to receive(:update_ope_from_crosswalk)
        InstitutionBuilder.run(user)
      end

      it 'calls rollup_sums for facility_code and ope6' do
        expect(Complaint).to receive(:rollup_sums).twice
        InstitutionBuilder.run(user)
      end

      it 'sums complaints by facility_code' do
        InstitutionBuilder.run(user)

        Complaint::FAC_CODE_ROLL_UP_SUMS.each_key do |column|
          expect(institution[column]).to eq(2)
        end
      end

      it 'sums complaints by ope6' do
        InstitutionBuilder.run(user)

        Complaint::OPE6_ROLL_UP_SUMS.each_key do |column|
          expect(institution[column]).to eq(2)
        end
      end
    end

    describe 'when adding Outcome data' do
      let(:institution) { institutions.find_by(facility_code: outcome.facility_code) }
      let(:outcome) { Outcome.first }

      before(:each) do
        create :outcome, :institution_builder
        InstitutionBuilder.run(user)
      end

      it 'copies columns used by institutions' do
        Outcome::COLS_USED_IN_INSTITUTION.each do |column|
          expect(outcome[column]).to eq(institution[column])
        end
      end
    end
  end
end

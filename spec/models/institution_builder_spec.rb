# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionBuilder, type: :model do
  let(:user) { User.first }
  let(:institutions) { Institution.where(version: Version.current_preview) }
  let(:factory_class) { InstitutionBuilder::Factory }

  before do
    create :user, email: 'fred@va.gov', password: 'fuggedabodit'
  end

  describe '#run' do
    before do
      create :weam, :institution_builder
      create :crosswalk, :institution_builder
    end

    context 'when successful' do
      it 'returns a success = true' do
        expect(described_class.run(user)[:success]).to be_truthy
      end

      it 'returns the new preview version record if successful' do
        create :version
        old_version = Version.current_preview
        version = described_class.run(user)[:version]
        expect(version).to eq(Version.current_preview)
        expect(version).not_to eq(old_version)
        expect(version.production).to be_falsey
        expect(version).not_to be_generating
      end

      it 'returns a nil error_msg if successful' do
        expect(described_class.run(user)[:error_msg]).to be_nil
      end

      it 'returns a success notice when successful' do
        expect(described_class.run(user)[:notice]).to eq('Institution build was successful')
      end
    end

    context 'when not successful' do
      it 'returns a success = false' do
        allow(factory_class).to receive(:add_crosswalk).and_raise(StandardError, 'BOOM!')
        expect(described_class.run(user)[:success]).to be_falsey
      end

      it 'returns an error message' do
        allow(factory_class).to receive(:add_crosswalk).and_raise(StandardError, 'BOOM!')
        expect(described_class.run(user)[:error_msg]).to eq('BOOM!')
      end

      it 'logs errors at the database level' do
        error_message = 'There was an error occurring at the database level: BOOM!'
        statement_invalid = ActiveRecord::StatementInvalid.new('BOOM!')
        statement_invalid.set_backtrace(%(backtrace))
        allow(factory_class).to receive(:add_crosswalk).and_raise(statement_invalid)
        allow(Rails.logger).to receive(:error).with(error_message)
        described_class.run(user)
        expect(Rails.logger).to have_received(:error).with(error_message)
      end

      it 'logs errors at the Rails level' do
        error_message = 'There was an error of unexpected origin: BOOM!'
        allow(factory_class).to receive(:add_crosswalk).and_raise(StandardError, 'BOOM!')
        allow(Rails.logger).to receive(:error).with(error_message)
        described_class.run(user)
        expect(Rails.logger).to have_received(:error).with(error_message)
      end

      it 'does not change the institutions or versions if not successful' do
        allow(factory_class).to receive(:add_crosswalk).and_raise(StandardError, 'BOOM!')
        create :version
        version = Version.current_preview
        described_class.run(user)
        expect(Institution.count).to be_zero
        expect(Version.current_preview).to eq(version)
      end
    end

    describe 'when initializing with Weam data' do
      let(:weam) { Weam.first }
      let(:institution) { institutions.first }

      before do
        described_class.run(user)
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

    describe 'when preventing duplicates' do
      it 'duplicates in WEAMs are not present in institutions' do
        create :weam, facility_code: '18181818', institution: 'REAL SCHOOL'
        create :weam, facility_code: '18181818', institution: 'FAKE SCHOOL'
        described_class.run(user)
        expect(institutions.where(facility_code: '18181818').count).to eq(1)
      end
    end

    describe 'when adding Crosswalk data' do
      let(:institution) { institutions.find_by(facility_code: crosswalk.facility_code) }
      let(:crosswalk) { Crosswalk.first }

      before do
        described_class.run(user)
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

      before do
        create :sva, :institution_builder
        described_class.run(user)
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

      before do
        create :vsoc, :institution_builder
        described_class.run(user)
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

      before do
        create :eight_key, :institution_builder
        described_class.run(user)
      end

      it 'sets eight_keys to TRUE for every eight_key record' do
        expect(institution.eight_keys).to be_truthy
      end
    end

    describe 'when adding Accreditation data' do
      let(:institution) { institutions.find_by(ope: accreditation_institute.ope) }
      let!(:accreditation_institute) { create :accreditation_institute_campus }

      describe 'with regards to the time frame' do
        it 'only adds current accreditations' do
          create :accreditation_record
          described_class.run(user)

          expect(institution.accreditation_type).not_to be_nil
        end

        it 'does not add non-current accreditations' do
          create :accreditation_record_expired
          described_class.run(user)

          expect(institution.accreditation_type).to be_nil
        end
      end

      describe 'with regards to the accrediting authority' do
        it 'adds institutional accreditations' do
          create :accreditation_record
          described_class.run(user)

          expect(institution.accreditation_type).not_to be_nil
        end

        it 'does not add non-institutional accreditations' do
          create :accreditation_record, program_id: 2
          described_class.run(user)

          expect(institution.accreditation_type).to be_nil
        end
      end

      describe 'the accreditation_type' do
        AccreditationRecord::ACCREDITATIONS.each_pair do |type, agency_regex_array|
          agency_regex_array.map(&:source).each do |agency_name|
            it "is set to #{type} when the agency name contains '#{agency_name}'" do
              create :accreditation_record, agency_name: 'Agency ' + agency_name
              described_class.run(user)

              expect(institution.accreditation_type).to eq(type)
            end
          end
        end

        it 'prefers national over hybrid' do
          create :accreditation_record, agency_name: 'Biblical School'
          create :accreditation_record, agency_name: 'Design School'
          described_class.run(user)

          expect(institution.accreditation_type).to eq('national')
        end

        it 'prefers regional over hybrid and national' do
          create :accreditation_record, agency_name: 'Biblical School'
          create :accreditation_record, agency_name: 'Middle School'
          create :accreditation_record, agency_name: 'Design School'
          described_class.run(user)
          expect(institution.accreditation_type).to eq('regional')
        end
      end

      describe 'the accreditation status' do
        it 'is set only for the `AccreditationAction::PROBATIONARY_STATUSES`' do
          create :accreditation_action
          described_class.run(user)
          expect(institution.accreditation_status).to be_nil
        end

        AccreditationAction::PROBATIONARY_STATUSES.each do |status|
          it "is set for #{status}" do
            create :accreditation_action, action_description: status[1..-2]
            described_class.run(user)
            expect(institution.accreditation_status).to eq(status[1..-2])
          end
        end

        AccreditationAction::RESTORATIVE_STATUSES.each do |status|
          it "with a more recent 'restorative' action for the institution does not set the `accreditation_status" do
            create :accreditation_action, action_description: AccreditationAction::PROBATIONARY_STATUSES.first[1..-2],
                                          action_date: '2019-01-06'
            create :accreditation_action, action_description: status[1..-2], action_date: '2019-01-09'
            described_class.run(user)
            expect(institution.accreditation_status).to be_nil
          end
        end

        it 'does not matter if an `accreditation_type` is set' do
          create :accreditation_action_probationary
          described_class.run(user)
          expect(institution.accreditation_status).to be_truthy
          expect(institution.accreditation_type).to be_nil
        end

        it 'does not matter if accreditation is current' do
          create :accreditation_record, accreditation_end_date: '2011-01-01'
          create :accreditation_action_probationary
          described_class.run(user)
          expect(institution.accreditation_status).to be_truthy
          expect(institution.accreditation_type).to be_nil
        end
      end

      describe 'the accreditation_action caution_flags' do
        it 'has flags for any non-nil status' do
          create :accreditation_action_probationary
          described_class.run(user)

          expect(CautionFlag
                     .where({ institution_id: institution.id,
                              source: AccreditationCautionFlag::NAME,
                              version_id: Version.current_preview.id })
                     .count).to be > 0
        end

        it 'has no flags for any nil status' do
          create :accreditation_action
          described_class.run(user)

          expect(CautionFlag
                     .where({ institution_id: institution.id,
                              source: AccreditationCautionFlag::NAME,
                              version_id: Version.current_preview.id })
                     .count).to eq(0)
        end

        it 'concatenates `action_description` and `justification_description`' do
          aap = create :accreditation_action_probationary

          described_class.run(user)

          caution_flags = CautionFlag.where({ institution_id: institution.id,
                                              source: AccreditationCautionFlag::NAME,
                                              version_id: Version.current_preview.id }).count
          expect(caution_flags).to be > 0
          expect(institutions.find(institution.id).caution_flag_reason)
            .to include(aap.action_description, aap.justification_description)
        end
      end
    end

    describe 'when adding ArfGiBill data' do
      let(:institution) { institutions.find_by(facility_code: arf_gi_bill.facility_code) }
      let(:arf_gi_bill) { ArfGiBill.first }

      before do
        create :arf_gi_bill, :institution_builder
        described_class.run(user)
      end

      it 'copies columns used by institutions' do
        expect(institution.gibill).to eq(arf_gi_bill.gibill)
      end
    end

    describe 'when adding Post911Stat' do
      let(:institution) { institutions.find_by(facility_code: post911_stat.facility_code) }
      let(:post911_stat) { Post911Stat.first }

      before do
        create :post911_stat, :institution_builder
        described_class.run(user)
      end

      it 'copies columns used by institutions' do
        expect(post911_stat.tuition_and_fee_count).to eq(institution.p911_recipients)
        expect(post911_stat.tuition_and_fee_total_amount).to eq(institution.p911_tuition_fees)
        expect(post911_stat.yellow_ribbon_count).to eq(institution.p911_yr_recipients)
        expect(post911_stat.yellow_ribbon_total_amount).to eq(institution.p911_yellow_ribbon)
      end
    end

    describe 'when adding Mou data' do
      let(:institution) { institutions.find_by(ope: mou.ope) }
      let(:mou) { Mou.first }

      it 'copies columns used by institutions' do
        create :mou, :institution_builder
        described_class.run(user)
        expect(mou.dodmou).to eq(institution.dodmou)
      end

      describe 'the mou caution_flag' do
        it 'has flags when dod_status is true' do
          create :mou, :institution_builder, :by_dod
          described_class.run(user)
          expect(CautionFlag
                     .where({ institution_id: institution.id,
                              source: MouCautionFlag::NAME,
                              version_id: Version.current_preview.id })
                     .count).to be > 0
        end

        it 'has no flags when dod_status is not true' do
          create :mou, :institution_builder, :by_title_iv
          described_class.run(user)
          expect(CautionFlag
                     .where({ institution_id: institution.id,
                              source: MouCautionFlag::NAME,
                              version_id: Version.current_preview.id })
                     .count).to eq(0)
        end
      end

      describe 'the caution_flag_reason' do
        it 'is set when dod_status is true' do
          create :mou, :institution_builder, :by_dod
          described_class.run(user)
          caution_flags = CautionFlag.where({ institution_id: institution.id,
                                              source: MouCautionFlag::NAME,
                                              version_id: Version.current_preview.id }).count
          expect(caution_flags).to be > 0

          expect(institutions.find(institution.id).caution_flag_reason)
            .to include('DoD Probation For Military Tuition Assistance')
        end
      end
    end

    describe 'when adding Scorecard data' do
      let(:institution) { institutions.find_by(cross: scorecard.cross) }
      let(:scorecard) { Scorecard.first }

      before do
        create :scorecard, :institution_builder
        described_class.run(user)
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

      before do
        create :ipeds_ic, :institution_builder
        described_class.run(user)
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

      before do
        create :ipeds_hd, :institution_builder
        described_class.run(user)
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

      before do
        create :ipeds_ic_ay, :institution_builder
        described_class.run(user)
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

      let(:nil_ipeds_ic_ay) { IpedsIcPy::COLS_USED_IN_INSTITUTION.index_with({}) { |v, o| o[v] = nil } }

      context 'when the institution fields are nil' do
        it 'copies columns used by institutions' do
          create :ipeds_ic_py, :institution_builder
          described_class.run(user)
          IpedsIcPy::COLS_USED_IN_INSTITUTION.each do |column|
            expect(ipeds_ic_py[column]).to eq(institution[column])
          end
        end
      end

      context 'when the institution fields are not nil' do
        def check_ipeds_ic_py
          IpedsIcPy::COLS_USED_IN_INSTITUTION.each do |column|
            expect(ipeds_ic_py[column]).not_to eq(institution[column])
          end
        end

        def check_ipeds_ic_ay
          IpedsIcAy::COLS_USED_IN_INSTITUTION.each do |column|
            expect(ipeds_ic_ay[column]).to eq(institution[column])
          end
        end

        it 'the institution record matches the ipeds_ic_ay record' do
          create :ipeds_ic_ay, :institution_builder
          create :ipeds_ic_py, :institution_builder
          described_class.run(user)
          check_ipeds_ic_py
          check_ipeds_ic_ay
        end
      end
    end

    describe 'when adding Sec702 and VA Caution Flag Sec702 data' do
      context 'when the school is non-public' do
        let(:weam_row) { create :weam, :private, state: 'NY' }

        it 'the institution is unaffected by VA Caution Flag values' do
          create :va_caution_flag, :not_sec_702, facility_code: weam_row.facility_code
          create :sec702, state: weam_row.state

          described_class.run(user)
          expect(institutions.find_by(facility_code: weam_row.facility_code).sec_702).to be_nil
        end

        it 'the institution is unaffected by Sec702' do
          create :sec702, state: weam_row.state

          described_class.run(user)
          expect(institutions.find_by(facility_code: weam_row.facility_code).sec_702).to be_nil
        end
      end

      describe 'when the school is public' do
        let(:weam_row) { create :weam, :public, state: 'NY' }

        it 'is set from Section702' do
          create :sec702, state: weam_row.state
          described_class.run(user)
          expect(institutions.find_by(facility_code: weam_row.facility_code).sec_702).not_to be_nil
          expect(institutions.find_by(facility_code: weam_row.facility_code).sec_702).to be_falsy
        end

        it 'is set from VA Caution Flags when a row exists' do
          create :va_caution_flag, :not_sec_702, facility_code: weam_row.facility_code
          create :sec702, state: weam_row.state, sec_702: true
          described_class.run(user)
          expect(institutions.find_by(facility_code: weam_row.facility_code).sec_702).not_to be_nil
          expect(institutions.find_by(facility_code: weam_row.facility_code).sec_702).to be_falsey
        end
      end

      describe 'the sec_702 caution_flag' do
        let(:weam_row) { create :weam, :public, state: 'NY' }

        it 'has flags from Section702 when sec_702 is false' do
          create :sec702, state: weam_row.state
          described_class.run(user)

          institution = institutions.find_by(facility_code: weam_row.facility_code)
          expect(CautionFlag
                     .where({ source: Sec702CautionFlag::NAME,
                              institution_id: institution.id,
                              version_id: Version.current_preview.id })
                     .count).to be > 0
        end

        it 'has flags from VA Caution Flags when sec_702 is false' do
          create :va_caution_flag, :not_sec_702, facility_code: weam_row.facility_code
          create :sec702, state: weam_row.state, sec_702: true

          described_class.run(user)

          institution = institutions.find_by(facility_code: weam_row.facility_code)
          expect(CautionFlag.where({ source: Sec702CautionFlag::NAME, institution_id: institution.id,
                                     version_id: Version.current_preview.id }).count).to be > 0
        end
      end
    end

    describe 'when adding Settlement data' do
      it 'a caution_flag is set with title and description' do
        weam_row = create :weam, :weam_builder
        va_caution_flag = create :va_caution_flag, :settlement, facility_code: weam_row.facility_code
        described_class.run(user)

        institution = institutions.find_by(facility_code: weam_row.facility_code)
        caution_flag = CautionFlag.where({ institution_id: institution.id, source: 'Settlement',
                                           version_id: Version.current_preview.id }).first

        expect(caution_flag.title).to eq(va_caution_flag.settlement_title)
        expect(caution_flag.description).to eq(va_caution_flag.settlement_description)
      end

      it 'a caution_flag is set with title and description for all with same IPEDs' do
        crosswalk1 = create :crosswalk
        crosswalk2 = create :crosswalk, cross: crosswalk1.cross
        weam_row1 = create :weam, :weam_builder, facility_code: crosswalk1.facility_code
        weam_row2 = create :weam, :weam_builder, facility_code: crosswalk2.facility_code
        va_caution_flag = create :va_caution_flag, :settlement, facility_code: crosswalk1.facility_code
        described_class.run(user)

        institution1 = institutions.find_by(facility_code: weam_row1.facility_code)
        institution2 = institutions.find_by(facility_code: weam_row2.facility_code)
        caution_flag1 = CautionFlag.where({ institution_id: institution1.id, source: 'Settlement',
                                            version_id: Version.current_preview.id }).first
        caution_flag2 = CautionFlag.where({ institution_id: institution2.id, source: 'Settlement',
                                            version_id: Version.current_preview.id }).first

        expect(caution_flag1.title).to eq(va_caution_flag.settlement_title)
        expect(caution_flag1.description).to eq(va_caution_flag.settlement_description)
        expect(caution_flag2.title).to eq(va_caution_flag.settlement_title)
        expect(caution_flag2.description).to eq(va_caution_flag.settlement_description)
      end

      it 'caution_flag_reason has multiple descriptions' do
        weam_row = create :weam, :weam_builder
        flag_a = create :va_caution_flag, :settlement, facility_code: weam_row.facility_code
        flag_b = create :va_caution_flag, :settlement, facility_code: weam_row.facility_code,
                                                       settlement_title: 'another title'
        described_class.run(user)
        institution = institutions.find_by(facility_code: weam_row.facility_code)
        caution_flags = CautionFlag.where({ institution_id: institution.id,
                                            source: 'Settlement', version_id: Version.current_preview.id }).count
        expect(caution_flags).to be > 1
        expect(institution.caution_flag_reason).to include(flag_a.settlement_title, flag_b.settlement_title)
      end
    end

    describe 'when adding Hcm data' do
      let(:institution) { institutions.find_by(ope6: hcm.ope6) }
      let(:hcm) { Hcm.first }

      describe 'the caution_flag' do
        it 'has flags for every heightened cash monitoring notice' do
          create :hcm, :institution_builder
          described_class.run(user)
          expect(CautionFlag
                     .where({ institution_id: institution.id,
                              source: HcmCautionFlag::NAME,
                              version_id: Version.current_preview.id })
                     .count).to be > 0
        end
      end

      describe 'the caution_flag_reason' do
        it 'has flag set to the hcm_reason' do
          create :hcm, :institution_builder
          described_class.run(user)
          caution_flags = CautionFlag.where({ institution_id: institution.id,
                                              source: HcmCautionFlag::NAME,
                                              version_id: Version.current_preview.id }).count

          expect(caution_flags).to be > 0
          expect(institutions.find(institution.id).caution_flag_reason)
            .to include(hcm.hcm_reason)
        end

        it 'has flag with multiple hcm_reason' do
          create :hcm, :institution_builder
          create :hcm, :institution_builder, hcm_reason: 'another reason'
          described_class.run(user)
          caution_flags = CautionFlag.where({ institution_id: institution.id, source: HcmCautionFlag::NAME,
                                              version_id: Version.current_preview.id }).count
          expect(caution_flags).to be > 0
          expect(institutions.find(institution.id).caution_flag_reason)
            .to include(hcm.hcm_reason, 'another reason')
        end
      end
    end

    describe 'when adding Complaint data' do
      let(:institution) { institutions.find_by(facility_code: complaint.facility_code) }
      let(:complaint) { Complaint.first }

      before do
        create_list :complaint, 2, :institution_builder, :all_issues
      end

      it 'calls update_ope_from_crosswalk' do
        allow(Complaint).to receive(:update_ope_from_crosswalk)
        described_class.run(user)
        expect(Complaint).to have_received(:update_ope_from_crosswalk)
      end

      it 'calls rollup_sums for facility_code and ope6' do
        allow(Complaint).to receive(:rollup_sums).twice
        described_class.run(user)
        expect(Complaint).to have_received(:rollup_sums).twice
      end

      it 'sums complaints by facility_code' do
        described_class.run(user)

        Complaint::FAC_CODE_ROLL_UP_SUMS.each_key do |column|
          expect(institution[column]).to eq(2)
        end
      end

      it 'sums complaints by ope6' do
        described_class.run(user)

        Complaint::OPE6_ROLL_UP_SUMS.each_key do |column|
          expect(institution[column]).to eq(2)
        end
      end
    end

    describe 'when adding Outcome data' do
      let(:institution) { institutions.find_by(facility_code: outcome.facility_code) }
      let(:outcome) { Outcome.first }

      before do
        create :outcome, :institution_builder
        described_class.run(user)
      end

      it 'copies columns used by institutions' do
        Outcome::COLS_USED_IN_INSTITUTION.each do |column|
          expect(outcome[column]).to eq(institution[column])
        end
      end
    end

    describe 'calculating stem_offered' do
      let(:stem_cip_code) { StemCipCode.first }
      let(:ipeds_cip_code) { IpedsCipCode.first }
      let(:institution) { institutions.find_by(cross: ipeds_cip_code.cross) }

      context 'with valid stem reference' do
        it 'updates stem_offered' do
          create :ipeds_cip_code, :institution_builder
          create :stem_cip_code
          described_class.run(user)
          expect(institution.stem_offered).to be(true)
        end
      end

      context 'without a cross record match to an ipeds cip code' do
        let(:institution) { Institution.first }

        it 'does not set stem_offered' do
          described_class.run(user)
          expect(institution.stem_offered).to be(false)
        end
      end

      context 'when ctotalt on ipeds record indicates no stem programs available' do
        it 'does not set stem_offered' do
          create :ipeds_cip_code, :institution_builder, ctotalt: 0
          create :stem_cip_code
          described_class.run(user)
          expect(institution.stem_offered).to be(false)
        end
      end

      context 'when there is no matching stem cip code' do
        it 'does not set stem_offered' do
          create :ipeds_cip_code, :institution_builder, cipcode: 0.3
          described_class.run(user)
          expect(institution.stem_offered).to be(false)
        end
      end
    end

    describe 'when adding Yellow Ribbon Program data' do
      let(:institution) { institutions.find_by(facility_code: yellow_ribbon_program_source.facility_code) }
      let(:yellow_ribbon_program_source) { YellowRibbonProgramSource.first }

      before do
        create :yellow_ribbon_program_source, :institution_builder
        described_class.run(user)
      end

      it 'generates a yellow ribbon program' do
        expect(institution.yellow_ribbon_programs.length).to eq(1)
      end

      it 'properly copies yellow ribbon program source data' do
        yrp = institution.yellow_ribbon_programs.first

        expect(yrp.degree_level).to eq(yellow_ribbon_program_source.degree_level)
        expect(yrp.division_professional_school).to eq(yellow_ribbon_program_source.division_professional_school)
        expect(yrp.number_of_students).to eq(yellow_ribbon_program_source.number_of_students)
        expect(yrp.contribution_amount).to eq(yellow_ribbon_program_source.contribution_amount)
      end
    end

    describe 'when adding School Closure data' do
      let(:institution) { institutions.find_by(facility_code: va_caution_flag.facility_code) }
      let(:va_caution_flag) { VaCautionFlag.first }

      before do
        create :va_caution_flag, :school_closing, facility_code: Weam.first.facility_code
        described_class.run(user)
      end

      it 'sets school_closing' do
        expect(institution.school_closing).to be_truthy
      end

      it 'sets school_closing_date' do
        expect(institution.school_closing_on)
          .to eq(Date.strptime(va_caution_flag.school_closing_date, '%m/%d/%y'))
      end
    end

    describe 'when adding Vet Tec Provider data' do
      before do
        create(:weam, :vet_tec)
        described_class.run(user)
      end

      let(:institution) { institutions.find_by(facility_code: '1VZZZZZZ') }

      it 'sets vet_tec_provider to true' do
        expect(institution.vet_tec_provider).to eq(true)
      end
    end

    describe 'when generating zipcode rates' do
      let(:institution) { institutions.find_by(zip: zipcode_rate.zip_code) }
      let(:zipcode_rate) { ZipcodeRate.first }

      before do
        create :weam, :zipcode_rate
        described_class.run(user)
      end

      it 'properly generates zipcode rates from weams data' do
        expect(zipcode_rate).not_to eq(nil)
        expect(zipcode_rate.zip_code).to eq(institution.zip)
        expect(zipcode_rate.mha_rate).to eq(1000)
        expect(zipcode_rate.mha_rate_grandfathered).to eq(1100)
        expect(zipcode_rate.version.id).to eq(Version.current_preview.id)
      end
    end

    describe 'when generating institution programs' do
      it 'properly generates institution programs from programs and edu_programs' do
        create :program, facility_code: '1ZZZZZZZ'
        create :edu_program, facility_code: '1ZZZZZZZ'

        expect { described_class.run(user) }.to change(InstitutionProgram, :count).from(0).to(1)
        expect(InstitutionProgram.first.institution_id).to eq(Institution.first.id)
        expect(Institution.first.version_id).to eq(Version.current_preview.id)
      end

      it 'does not generate duplicate institution programs for duplicate edu-programs' do
        create :program, facility_code: '1ZZZZZZZ'
        create :edu_program, facility_code: '1ZZZZZZZ'
        create :edu_program, facility_code: '1ZZZZZZZ'

        expect { described_class.run(user) }.to change(InstitutionProgram, :count).from(0).to(1)
      end

      it 'does not generate duplicate institution programs for duplicate edu-programs with differently cased names' do
        create :program, facility_code: '1ZZZZZZZ'
        create :edu_program, facility_code: '1ZZZZZZZ', vet_tec_program: 'computer science'
        create :edu_program, facility_code: '1ZZZZZZZ'

        expect { described_class.run(user) }.to change(InstitutionProgram, :count).from(0).to(1)
      end

      it 'does not generate duplicate institution programs for duplicate programs' do
        create :program, facility_code: '1ZZZZZZZ'
        create :program, facility_code: '1ZZZZZZZ'
        create :edu_program, facility_code: '1ZZZZZZZ'

        expect { described_class.run(user) }.to change(InstitutionProgram, :count).from(0).to(1)
      end

      it 'does not generate duplicate institution programs for duplicate programs with differently cased names' do
        create :program, facility_code: '1ZZZZZZZ', description: 'computer science'
        create :program, facility_code: '1ZZZZZZZ'
        create :edu_program, facility_code: '1ZZZZZZZ'

        expect { described_class.run(user) }.to change(InstitutionProgram, :count).from(0).to(1)
      end

      it 'defaults deduped InstitutionProgram length_in_weeks to 0' do
        create :program, facility_code: '1ZZZZZZZ'
        create :edu_program, facility_code: '1ZZZZZZZ'
        create :edu_program, facility_code: '1ZZZZZZZ'

        expect { described_class.run(user) }.to change(InstitutionProgram, :count).from(0).to(1)
        expect(InstitutionProgram.first.length_in_weeks).to eq(0)
      end

      it 'does not generate institution programs without matching programs and edu_programs' do
        create :program, facility_code: '1ZZZZZZZ'
        create :edu_program, facility_code: '0001'
        described_class.run(user)
        expect(InstitutionProgram.count).to eq(0)
      end
    end

    describe 'when setting extension campus_type' do
      before do
        create(:weam, :extension)
        create(:weam, facility_code: '10X00001', campus_type: 'Y')
        described_class.run(user)
      end

      it 'sets campus_type to "E"' do
        extension = institutions.find_by(facility_code: '10X00000')
        expect(extension.campus_type).to eq('E')
      end

      it 'ignores for instituions with campus_type' do
        extension = institutions.find_by(facility_code: '10X00001')
        expect(extension.campus_type).to eq('Y')
      end
    end

    describe 'when setting approved' do
      before do
        create(:weam, :as_vet_tec_provider)
        described_class.run(user)
      end

      it 'sets correctly for VET TEC institution' do
        expect(institutions.find_by(facility_code: '1VZZZZZZ').approved).to be_truthy
      end
    end

    describe 'when creating versioned_school_certifying_officials' do
      it 'properly generates school certifying official with instituion_id' do
        weam = create(:weam)
        create :school_certifying_official, facility_code: weam.facility_code
        expect { described_class.run(user) }.to change(VersionedSchoolCertifyingOfficial, :count).from(0).to(1)
        expect(VersionedSchoolCertifyingOfficial.last.institution_id).to be_present
      end

      it 'ignores priority casing' do
        weam = create(:weam)
        create :school_certifying_official, facility_code: weam.facility_code, priority: 'primarY'
        expect { described_class.run(user) }.to change(VersionedSchoolCertifyingOfficial, :count).from(0).to(1)
        expect(VersionedSchoolCertifyingOfficial.last.institution_id).to be_present
      end

      it 'does not create VSCO for SCO with invalid priority value' do
        weam = create(:weam)
        create :school_certifying_official, :invalid_priority, facility_code: weam.facility_code
        described_class.run(user)
        expect(VersionedSchoolCertifyingOfficial.count).to be_zero
      end
    end

    describe 'when setting section 103 data' do
      it 'sets default message for IHL institutions' do
        weam = create :weam, :ihl_facility_code
        described_class.run(user)

        expect(institutions.where("facility_code = '#{weam.facility_code}'").first['section_103_message'])
          .to eq(Institution::DEFAULT_IHL_SECTION_103_MESSAGE)
      end

      it 'does not set default message for nonIHL institutions' do
        weam = create :weam
        described_class.run(user)

        expect(institutions.where("facility_code = '#{weam.facility_code}'").first['section_103_message'])
          .to be_nil
      end

      it 'sets certificate required message' do
        weam = create :weam, :ihl_facility_code
        create :sec103, facility_code: weam.facility_code

        described_class.run(user)

        expect(institutions.where("facility_code = '#{weam.facility_code}'").first['section_103_message'])
          .to eq('Requires Certificate of Eligibility (COE)')
      end

      it 'sets certificate required plus additional message' do
        weam = create :weam, :ihl_facility_code
        create :sec103, :requires_additional, facility_code: weam.facility_code

        described_class.run(user)

        expect(institutions.where("facility_code = '#{weam.facility_code}'").first['section_103_message'])
          .to eq('Requires Certificate of Eligibility (COE) and additional criteria')
      end

      it 'institutions that explicitly do not comply with section 103 are not approved ' do
        weam = create :weam, :ihl_facility_code, :approved_poo_and_law_code, :with_approved_indicators
        create :sec103, :does_not_comply, facility_code: weam.facility_code

        described_class.run(user)

        expect(institutions.where("facility_code = '#{weam.facility_code}'").first['approved']).to eq(false)
      end
    end

    describe 'when calculating category ratings' do
      let(:institution) { institutions.find_by(facility_code: weam.facility_code) }
      let(:weam) { Weam.find_by(facility_code: '11000000') }

      before do
        create :weam, :ihl_facility_code
      end

      it 'counts number of total institution ratings' do
        create_list(:school_rating, 7, :ihl_facility_code, :all_threes)
        create(:school_rating)

        described_class.run(user)

        expect(institution.rating_count).to eq(7)
      end

      it 'averages overall institution rating' do
        create_list(:school_rating, 3, :ihl_facility_code, :all_threes)

        described_class.run(user)

        expect(institution.rating_average).to eq(3)
      end

      it 'institution rating is null without any ratings' do
        described_class.run(user)

        expect(institution.rating_average).to be_nil
      end

      it 'creates a InstitutionCategoryRating for every category' do
        create_list(:school_rating, 3, :ihl_facility_code, :online_instruction_only)

        described_class.run(user)
        expect(InstitutionCategoryRating.where("institution_id='#{institution.id}'").count).to eq(7)
      end

      it 'counts ratings correctly' do
        create(:school_rating, :ihl_facility_code, online_instruction: 5)
        create(:school_rating, :ihl_facility_code, online_instruction: 4)
        create(:school_rating, :ihl_facility_code, online_instruction: 3)
        create(:school_rating, :ihl_facility_code, :next_day, online_instruction: 1)

        described_class.run(user)

        online_instruction = InstitutionCategoryRating
                             .find_by(institution_id: institution.id, category_name: 'online_instruction')

        expect(online_instruction.rated1_count).to eq(1)
        expect(online_instruction.rated2_count).to eq(0)
        expect(online_instruction.rated3_count).to eq(1)
        expect(online_instruction.rated4_count).to eq(1)
        expect(online_instruction.rated5_count).to eq(1)
        expect(online_instruction.na_count).to eq(0)
        expect(online_instruction.total_count).to eq(4)
        expect(online_instruction.average_rating).to eq(3.25)
      end

      it 'ignores "NA" votes when calculating category average' do
        create(:school_rating, :ihl_facility_code, overall_experience: 3)
        create(:school_rating, :ihl_facility_code, overall_experience: 3)
        create(:school_rating, :ihl_facility_code)

        described_class.run(user)

        overall_experience = InstitutionCategoryRating
                             .find_by(institution_id: institution.id, category_name: 'overall_experience')
        expect(overall_experience.rated1_count).to eq(0)
        expect(overall_experience.rated2_count).to eq(0)
        expect(overall_experience.rated3_count).to eq(2)
        expect(overall_experience.rated4_count).to eq(0)
        expect(overall_experience.rated5_count).to eq(0)
        expect(overall_experience.na_count).to eq(1)
        expect(overall_experience.total_count).to eq(2)
        expect(overall_experience.average_rating).to eq(3)
      end

      it 'only counts most recent rating by rater' do
        create_list(:school_rating, 4, :ihl_facility_code, online_instruction: 2)
        create(:school_rating, :ihl_facility_code, online_instruction: 2, rater_id: 'test')
        create(:school_rating, :ihl_facility_code, :next_day, online_instruction: 5, rater_id: 'test')

        described_class.run(user)

        online_instruction = InstitutionCategoryRating
                             .find_by(institution_id: institution.id, category_name: 'online_instruction')

        expect(online_instruction.rated1_count).to eq(0)
        expect(online_instruction.rated2_count).to eq(4)
        expect(online_instruction.rated3_count).to eq(0)
        expect(online_instruction.rated4_count).to eq(0)
        expect(online_instruction.rated5_count).to eq(1)
        expect(online_instruction.na_count).to eq(0)
        expect(online_instruction.total_count).to eq(5)
        expect(online_instruction.average_rating).to eq(2.6)
      end

      it 'treats rating <= 0 as NA' do
        create(:school_rating, :ihl_facility_code, overall_experience: 3)
        create(:school_rating, :ihl_facility_code, overall_experience: 3)
        create(:school_rating, :ihl_facility_code, overall_experience: 0)
        create(:school_rating, :ihl_facility_code, overall_experience: -1)

        described_class.run(user)

        overall_experience = InstitutionCategoryRating
                             .find_by(institution_id: institution.id, category_name: 'overall_experience')
        expect(overall_experience.rated1_count).to eq(0)
        expect(overall_experience.rated2_count).to eq(0)
        expect(overall_experience.rated3_count).to eq(2)
        expect(overall_experience.rated4_count).to eq(0)
        expect(overall_experience.rated5_count).to eq(0)
        expect(overall_experience.na_count).to eq(2)
        expect(overall_experience.total_count).to eq(2)
        expect(overall_experience.average_rating).to eq(3)
      end

      it 'treats rating > 5 as 5' do
        create(:school_rating, :ihl_facility_code, overall_experience: 6)
        create(:school_rating, :ihl_facility_code, overall_experience: 6)

        described_class.run(user)

        overall_experience = InstitutionCategoryRating
                             .find_by(institution_id: institution.id, category_name: 'overall_experience')
        expect(overall_experience.rated1_count).to eq(0)
        expect(overall_experience.rated2_count).to eq(0)
        expect(overall_experience.rated3_count).to eq(0)
        expect(overall_experience.rated4_count).to eq(0)
        expect(overall_experience.rated5_count).to eq(2)
        expect(overall_experience.na_count).to eq(0)
        expect(overall_experience.total_count).to eq(2)
        expect(overall_experience.average_rating).to eq(5)
      end

      it 'calculates a null average for 0 votes' do
        create(:school_rating, :ihl_facility_code)
        create(:school_rating, :ihl_facility_code)

        described_class.run(user)

        overall_experience = InstitutionCategoryRating
                             .find_by(institution_id: institution.id, category_name: 'overall_experience')
        expect(overall_experience.rated1_count).to eq(0)
        expect(overall_experience.rated2_count).to eq(0)
        expect(overall_experience.rated3_count).to eq(0)
        expect(overall_experience.rated4_count).to eq(0)
        expect(overall_experience.rated5_count).to eq(0)
        expect(overall_experience.na_count).to eq(2)
        expect(overall_experience.total_count).to eq(0)
        expect(overall_experience.average_rating).to be_nil
      end
    end

    describe 'when missing latitude and longitude' do
      it 'sets latitude and longitdue from CensusLatLong' do
        weam = create(:weam)
        census_lat_long = create(:census_lat_long, facility_code: weam.facility_code)
        described_class.run(user)
        institution = institutions.where(facility_code: weam.facility_code).first
        expect(institution.longitude.to_s).to eq(census_lat_long.interpolated_longitude_latitude.split(',')[0])
        expect(institution.latitude.to_s).to eq(census_lat_long.interpolated_longitude_latitude.split(',')[1])
      end

      it 'sets latitude and longitude from previous version' do
        create(:version, :production)
        prod_institution = create(:institution, :lat_long, :physical_address, version_id: Version.current_production.id)
        weam = create(:weam, facility_code: prod_institution.facility_code, approved: true,
                             physical_address_1: prod_institution.physical_address_1,
                             physical_address_2: prod_institution.physical_address_2,
                             physical_address_3: prod_institution.physical_address_3,
                             physical_city: prod_institution.physical_city,
                             physical_state: prod_institution.physical_state,
                             physical_country: prod_institution.physical_country,
                             physical_zip: prod_institution.physical_zip)

        described_class.run(user)
        prev_institution = institutions.where(facility_code: weam.facility_code,
                                              version_id: Version.current_preview.id).first

        expect(prod_institution.facility_code).to eq(prev_institution.facility_code)
        expect(prod_institution.physical_address).to eq(prev_institution.physical_address)
        expect(prod_institution.latitude).to eq(prev_institution.latitude)
        expect(prod_institution.longitude).to eq(prev_institution.longitude)
      end
    end
  end
end

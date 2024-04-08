# frozen_string_literal: true

require 'rails_helper'
require_relative './shared_setup'

RSpec.describe InstitutionBuilder, type: :model do
  include_context('with setup')

  describe '#run' do
    before do
      create :weam, :institution_builder
      create :crosswalk, :institution_builder
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
                     .where({ source: CautionFlagTemplates::Sec702CautionFlag::NAME,
                              institution_id: institution.id,
                              version_id: Version.current_production.id })
                     .count).to be > 0
        end

        it 'has flags from VA Caution Flags when sec_702 is false' do
          create :va_caution_flag, :not_sec_702, facility_code: weam_row.facility_code
          create :sec702, state: weam_row.state, sec_702: true

          described_class.run(user)

          institution = institutions.find_by(facility_code: weam_row.facility_code)
          expect(CautionFlag.where({ source: CautionFlagTemplates::Sec702CautionFlag::NAME, institution_id: institution.id,
                                     version_id: Version.current_production.id }).count).to be > 0
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
                                           version_id: Version.current_production.id }).first

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
                                            version_id: Version.current_production.id }).first
        caution_flag2 = CautionFlag.where({ institution_id: institution2.id, source: 'Settlement',
                                            version_id: Version.current_production.id }).first

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
                                            source: 'Settlement', version_id: Version.current_production.id }).count
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
                              source: CautionFlagTemplates::HcmCautionFlag::NAME,
                              version_id: Version.current_production.id })
                     .count).to be > 0
        end
      end

      describe 'the caution_flag_reason' do
        it 'has flag set to the hcm_reason' do
          create :hcm, :institution_builder
          described_class.run(user)
          caution_flags = CautionFlag.where({ institution_id: institution.id,
                                              source: CautionFlagTemplates::HcmCautionFlag::NAME,
                                              version_id: Version.current_production.id }).count

          expect(caution_flags).to be > 0
          expect(institutions.find(institution.id).caution_flag_reason)
            .to include(hcm.hcm_reason)
        end

        it 'has flag with multiple hcm_reason' do
          create :hcm, :institution_builder
          create :hcm, :institution_builder, hcm_reason: 'another reason'
          described_class.run(user)
          caution_flags = CautionFlag.where({ institution_id: institution.id, source: CautionFlagTemplates::HcmCautionFlag::NAME,
                                              version_id: Version.current_production.id }).count
          expect(caution_flags).to be > 0
          expect(institutions.find(institution.id).caution_flag_reason)
            .to include(hcm.hcm_reason, 'another reason')
        end
      end
    end
  end
end

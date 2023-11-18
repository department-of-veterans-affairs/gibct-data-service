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
          # vfep-847 this will not be the case for cross, ope & ope6 as they
          # added to the list of columns to pull in from weams and in this
          # context they are nil and the values are supplied from crosswalk
          next if %i[cross ope ope6].include?(column)

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

    describe 'when adding Crosswalk data and weams does not populate cross & ope' do
      let(:institution) { institutions.find_by(facility_code: crosswalk.facility_code) }
      let(:crosswalk) { Crosswalk.first }

      before do
        described_class.run(user)
      end

      it 'copies columns used by institutions when weams does not populate xwalk data' do
        Crosswalk::COLS_USED_IN_INSTITUTION.each do |column|
          expect(crosswalk[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding Crosswalk data and weams populates cross & ope' do
      let(:institution) { institutions.find_by(facility_code: crosswalk.facility_code) }
      let(:crosswalk) { Crosswalk.first }

      before do
        weam = Weam.first
        # rubocop:disable Rails/SkipsModelValidations
        weam.update_columns(cross: '2YYYYYYY', ope: '00380200')
        # rubocop:enable Rails/SkipsModelValidations

        described_class.run(user)
      end

      it 'copies columns used by institutions when weams does not populate xwalk data' do
        Crosswalk::COLS_USED_IN_INSTITUTION.each do |column|
          expect(crosswalk[column]).not_to eq(institution[column])
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
                              version_id: Version.current_production.id })
                     .count).to be > 0
        end

        it 'has no flags when dod_status is not true' do
          create :mou, :institution_builder, :by_title_iv
          described_class.run(user)
          expect(CautionFlag
                     .where({ institution_id: institution.id,
                              source: MouCautionFlag::NAME,
                              version_id: Version.current_production.id })
                     .count).to eq(0)
        end
      end

      describe 'the caution_flag_reason' do
        it 'is set when dod_status is true' do
          create :mou, :institution_builder, :by_dod
          described_class.run(user)
          caution_flags = CautionFlag.where({ institution_id: institution.id,
                                              source: MouCautionFlag::NAME,
                                              version_id: Version.current_production.id }).count
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
        create :scorecard, :institution_builder, :new_mission_fields
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
  end
end

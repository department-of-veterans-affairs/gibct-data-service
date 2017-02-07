# frozen_string_literal: true
require 'rails_helper'

RSpec.describe InstitutionBuilder, type: :model do
  let(:tables) { InstitutionBuilder::TABLES.map { |t| t.name.underscore.to_sym } }

  let(:valid_user) { User.first }
  let(:invalid_user) { User.new email: valid_user.email + 'xyz' }

  let(:institutions) { Institution.version(Version.preview_version.number) }

  before(:each) do
    create :user, email: 'fred@va.gov', password: 'fuggedabodit'
    tables.each { |table| create table, :institution_builder }
  end

  describe '#buildable?' do
    context 'where all csvs are populated' do
      it { expect(InstitutionBuilder).to be_buildable }
    end

    context 'where at least one csv is not populated' do
      before(:each) { InstitutionBuilder::TABLES.first.delete_all }
      it { expect(InstitutionBuilder).not_to be_buildable }
    end
  end

  describe '#valid_user?' do
    context 'with a valid user' do
      it { expect(InstitutionBuilder.valid_user?(valid_user)).to be_truthy }
    end

    context 'with an invalid user' do
      it { expect(InstitutionBuilder.valid_user?(invalid_user)).to be_falsey }
    end
  end

  describe '#run' do
    context 'with a valid user' do
      it 'returns the new preview version record if sucessful' do
        InstitutionBuilder.run(valid_user)
        version = InstitutionBuilder.run(valid_user)

        expect(version).to eq(Version.preview_version)
        expect(version.production).to be_falsey
      end

      it 'returns nil if not buildable' do
        InstitutionBuilder::TABLES.first.delete_all
        expect(InstitutionBuilder.run(valid_user)).to be_nil
      end
    end

    context 'with an invalid user' do
      it 'raises ArgumentError' do
        expect { InstitutionBuilder.run(invalid_user) }
          .to raise_exception(ArgumentError, Regexp.new(invalid_user.email, 'i'))
      end
    end

    describe 'when initializing with Weam data' do
      before(:each) do
        InstitutionBuilder.run(valid_user)
      end

      it 'adds approved schools' do
        expect(institutions.count).to eq(1)
      end

      it 'does not add non-approved schools' do
        # add 2nd school
        create :weam, poo_status: 'nasty poo'
        InstitutionBuilder.run(valid_user)

        expect(institutions.count).to eq(1)
      end

      it 'the new institution record matches the weam record' do
        weam = Weam.first
        institution = institutions.first

        Weam::USE_COLUMNS.each do |column|
          expect(weam[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding Crosswalk data' do
      let(:institution) { institutions.find_by(facility_code: crosswalk.facility_code) }
      let(:crosswalk) { Crosswalk.first }

      before(:each) do
        InstitutionBuilder.run(valid_user)
      end

      it 'the new institution record matches the crosswalk record' do
        Crosswalk::USE_COLUMNS.each do |column|
          expect(crosswalk[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding Sva data' do
      let(:institution) { institutions.find_by(cross: sva.cross) }
      let(:sva) { Sva.first }

      before(:each) do
        InstitutionBuilder.run(valid_user)
      end

      it 'the new institution record matches the sva record' do
        expect(institution.student_veteran_link).to eq(sva.student_veteran_link)
      end

      it 'sets student_veteran to TRUE for every sva record matched to institutions' do
        expect(institution.student_veteran).to be_truthy
      end
    end

    describe 'when adding Vsoc data' do
      let(:institution) { institutions.find_by(facility_code: vsoc.facility_code) }
      let(:vsoc) { Vsoc.first }

      before(:each) do
        InstitutionBuilder.run(valid_user)
      end

      it 'the new institution record matches the vsoc record' do
        Vsoc::USE_COLUMNS.each do |column|
          expect(vsoc[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding EightKey data' do
      let(:institution) { institutions.find_by(cross: eight_key.cross) }
      let(:eight_key) { EightKey.first }

      before(:each) do
        InstitutionBuilder.run(valid_user)
      end

      it 'sets eight_keys to TRUE for every eight_key record matched to institutions' do
        expect(institution.eight_keys).to be_truthy
      end
    end

    describe 'when adding Accreditation data' do
      let(:institution) { institutions.find_by(cross: accreditation.cross) }
      let(:accreditation) { Accreditation.first }

      before(:each) do
        Accreditation.delete_all
        Mou.first.update(status: nil)
      end

      describe 'when accessing the accreditation time frame' do
        it 'adds current accreditations' do
          create :accreditation, :institution_builder, periods: '12/12/2012 - current'
          InstitutionBuilder.run(valid_user)

          expect(institutions.first.accreditation_type).not_to be_nil
        end

        it 'does not add non-current accreditations' do
          create :accreditation, :institution_builder, periods: 'expired accreditation'
          InstitutionBuilder.run(valid_user)

          expect(Institution.first.accreditation_type).to be_nil
        end
      end

      describe 'when accessing the type of accrediting authority' do
        it 'adds non-institutional accreditations' do
          create :accreditation, :institution_builder, csv_accreditation_type: 'institutional'
          InstitutionBuilder.run(valid_user)

          expect(institutions.first.accreditation_type).not_to be_nil
        end

        it 'does not add non-institutional accreditations' do
          create :accreditation, :institution_builder, csv_accreditation_type: 'specialized'
          InstitutionBuilder.run(valid_user)

          expect(institutions.first.accreditation_type).to be_nil
        end
      end

      describe 'when accessing the accreditation type' do
        { 'hybrid' => 'Design', 'national' => 'Biblical', 'regional' => 'Middle' }.each_pair do |type, name|
          it "sets the accreditation_type for #{name}" do
            create :accreditation, :institution_builder, agency_name: name
            InstitutionBuilder.run(valid_user)

            expect(institutions.first.accreditation_type).to eq(type)
          end
        end

        it 'prefers national over hybrid' do
          create :accreditation, :institution_builder, agency_name: 'Design School'
          create :accreditation, :institution_builder, agency_name: 'Biblical School'
          InstitutionBuilder.run(valid_user)

          expect(institutions.first.accreditation_type).to eq('national')
        end

        it 'prefers regional over hybrid and national' do
          create :accreditation, :institution_builder, agency_name: 'Design School'
          create :accreditation, :institution_builder, agency_name: 'Biblical School'
          create :accreditation, :institution_builder, agency_name: 'Middle School'
          InstitutionBuilder.run(valid_user)

          expect(institutions.first.accreditation_type).to eq('regional')
        end
      end

      describe 'when accessing the accreditation status' do
        it "sets status and only for probation and 'show cause'" do
          create :accreditation, :institution_builder, accreditation_status: 'expired'
          InstitutionBuilder.run(valid_user)

          expect(institutions.first.accreditation_status).to be_nil
        end

        it "prefers 'show cause' over probation" do
          create :accreditation, :institution_builder, accreditation_status: 'show cause'
          create :accreditation, :institution_builder, accreditation_status: 'probation'
          InstitutionBuilder.run(valid_user)

          expect(institutions.first.accreditation_status).to eq('show cause')
        end
      end

      describe 'when setting caution flags' do
        it 'sets the flag for when the accreditation_status is set' do
          create :accreditation, :institution_builder, accreditation_status: 'expired'
          InstitutionBuilder.run(valid_user)

          expect(institutions.first.caution_flag).to be_truthy
        end

        it 'does not set the flag when the accreditation status is nil' do
          create :accreditation, :institution_builder, accreditation_status: nil
          InstitutionBuilder.run(valid_user)

          expect(institutions.first.caution_flag).to be_falsey
        end
      end

      describe 'when setting the caution flag reason' do
        it 'concatentates multiple accreditation cautions' do
          create :accreditation, :institution_builder, accreditation_status: 'show cause'
          create :accreditation, :institution_builder, accreditation_status: 'probation'
          create :accreditation, :institution_builder, accreditation_status: 'expired'
          InstitutionBuilder.run(valid_user)

          expect(institutions.first.caution_flag_reason).to match(/.*show cause.*/)
        end
      end
    end

    describe 'when adding ArfGiBill data' do
      let(:institution) { institutions.find_by(facility_code: arf_gi_bill.facility_code) }
      let(:arf_gi_bill) { ArfGiBill.first }

      before(:each) do
        InstitutionBuilder.run(valid_user)
      end

      it 'sets arf_gi_bills for every insitution matched by facility_code' do
        expect(institution.gibill).to eq(arf_gi_bill.gibill)
      end
    end

    describe 'when adding P911Tf data' do
      let(:institution) { institutions.find_by(facility_code: p911_tf.facility_code) }
      let(:p911_tf) { P911Tf.first }

      before(:each) do
        InstitutionBuilder.run(valid_user)
      end

      it 'the new institution record matches the p911_tf record' do
        P911Tf::USE_COLUMNS.each do |column|
          expect(p911_tf[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding P911Yr data' do
      let(:institution) { institutions.find_by(facility_code: p911_yr.facility_code) }
      let(:p911_yr) { P911Yr.first }

      before(:each) do
        InstitutionBuilder.run(valid_user)
      end

      it 'the new institution record matches the p911_yr record' do
        P911Yr::USE_COLUMNS.each do |column|
          expect(p911_yr[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding Mou data' do
      let(:institution) { institutions.find_by(ope6: mou.ope6) }
      let(:crosswalk) { Crosswalk.find_by(ope6: Mou.first.ope6) }
      let(:accreditation) { Accreditation.find_by(cross: crosswalk.cross) }
      let(:reason) { 'DoD Probation For Military Tuition Assistance' }
      let(:mou) { Mou.first }

      it 'the new institution record matches the mou record' do
        InstitutionBuilder.run(valid_user)

        expect(mou.dodmou).to eq(institution.dodmou)
      end

      describe 'when accessing the caution flag' do
        it 'sets the flag when dod_status is true' do
          accreditation.update(accreditation_status: nil)
          InstitutionBuilder.run(valid_user)

          expect(institution.caution_flag).to be_truthy
        end

        it 'does not set the flag when dod_status is not true' do
          mou.update(status: nil)
          accreditation.update(accreditation_status: nil)
          InstitutionBuilder.run(valid_user)

          expect(institution.caution_flag).to be_falsey
        end
      end

      describe 'when accessing the caution flag reason' do
        it 'sets the reason when dod_status is true' do
          accreditation.update(accreditation_status: nil)
          InstitutionBuilder.run(valid_user)

          expect(institution.caution_flag_reason).to eq(reason)
        end

        it 'appends to the existing caution flag reasons when dod_status is true' do
          accreditation.update(accreditation_status: 'probation')
          InstitutionBuilder.run(valid_user)

          expect(institution.caution_flag_reason).to match(/.*DoD.*/)
          expect(institution.caution_flag_reason).to match(/.*probation.*/)
        end

        it 'does not alter existing caution flag reasons when dod_status is not true' do
          mou.update(status: nil)
          accreditation.update(accreditation_status: 'probation')
          InstitutionBuilder.run(valid_user)

          expect(institution.caution_flag_reason).not_to match(/.*DoD.*/)
          expect(institution.caution_flag_reason).to match(/.*probation.*/)
        end
      end
    end

    describe 'when adding Scorecard data' do
      let(:institution) { institutions.find_by(cross: scorecard.cross) }
      let(:scorecard) { Scorecard.first }

      before(:each) do
        InstitutionBuilder.run(valid_user)
      end

      it 'the new institution record matches the scorecard record' do
        Scorecard::USE_COLUMNS.each do |column|
          expect(scorecard[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding IpedsIc data' do
      let(:institution) { institutions.find_by(cross: ipeds_ic.cross) }
      let(:ipeds_ic) { IpedsIc.first }

      before(:each) do
        InstitutionBuilder.run(valid_user)
      end

      it 'the new institution record matches the ipeds_ic record' do
        IpedsIc::USE_COLUMNS.each do |column|
          # expect(ipeds_ic[column]).to eq(institution[column])
        end
      end
    end
  end
end

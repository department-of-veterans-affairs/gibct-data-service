# frozen_string_literal: true
require 'rails_helper'

RSpec.describe InstitutionBuilder, type: :model do
  let(:tables) { InstitutionBuilder::TABLES.map { |t| t.name.underscore.to_sym } }
  let(:valid_user) { User.first }
  let(:invalid_user) { User.new email: valid_user.email + 'xyz' }

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
      it 'creates a new preview version record' do
        expect { InstitutionBuilder.run(valid_user) }.to change { Version.count }.by(1)
      end

      it 'returns the new preview version record if sucessful' do
        version = InstitutionBuilder.run(valid_user)

        expect(version).to eq(Version.first)
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
      it 'adds only approved schools' do
        create :weam, poo_status: 'nasty poo'
        expect { InstitutionBuilder.run(valid_user) }.to change { Institution.count }.by(1)
      end

      it 'the new institution record matches the weam record' do
        InstitutionBuilder.run(valid_user)

        weam = Weam.first
        institution = Institution.first

        Weam::USE_COLUMNS.each do |column|
          expect(weam[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding Crosswalk data' do
      it 'the new institution record matches the crosswalk record' do
        InstitutionBuilder.run(valid_user)

        crosswalk = Crosswalk.first
        institution = Institution.find_by(facility_code: crosswalk.facility_code)

        Crosswalk::USE_COLUMNS.each do |column|
          expect(crosswalk[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding Sva data' do
      it 'the new institution record matches the sva record' do
        InstitutionBuilder.run(valid_user)

        sva = Sva.first
        institution = Institution.find_by(cross: sva.cross)

        Sva::USE_COLUMNS.each do |column|
          expect(sva[column]).to eq(institution[column])
        end
      end

      it 'sets student_veteran to TRUE for every sva record matched to institutions' do
        InstitutionBuilder.run(valid_user)

        sva = Sva.first
        institution = Institution.find_by(cross: sva.cross)
        expect(institution.student_veteran).to be_truthy
      end
    end

    describe 'when adding Vsoc data' do
      it 'the new institution record matches the vsoc record' do
        InstitutionBuilder.run(valid_user)

        vsoc = Vsoc.first
        institution = Institution.find_by(facility_code: vsoc.facility_code)

        Vsoc::USE_COLUMNS.each do |column|
          expect(vsoc[column]).to eq(institution[column])
        end
      end
    end

    describe 'when adding Vsoc data' do
      it 'sets eight_keys to TRUE for every eight_key record matched to institutions' do
        InstitutionBuilder.run(valid_user)

        eight_key = EightKey.first
        institution = Institution.find_by(cross: eight_key.cross)
        expect(institution.eight_keys).to be_truthy
      end
    end
  end
end

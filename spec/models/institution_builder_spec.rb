# frozen_string_literal: true
require 'rails_helper'

RSpec.describe InstitutionBuilder, type: :model, focus: true do
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
        institution = Institution.first

        Crosswalk::USE_COLUMNS.each do |column|
          expect(crosswalk[column]).to eq(institution[column])
        end
      end
    end
  end
end

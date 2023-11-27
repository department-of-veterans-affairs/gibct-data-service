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

    # test one of each type. Since this can change over time and online, we cannot exhustively test all of the keywords.
    describe 'when adding Accreditation data' do
      let(:institution) { institutions.find_by(ope: accreditation_institute.ope) }
      let!(:accreditation_institute) { create :accreditation_institute_campus }

      describe 'the regional accreditation_type' do
        it 'sets the regional accreditation_type' do
          create(:accreditation_type_keyword, :accreditation_type_regional)
          create(:regional_accreditation_type)
          described_class.run(user)
          expect(institution.accreditation_type).to eq('regional')
        end
      end

      describe 'the national accreditation_type' do
        it 'sets the national accreditation_type' do
          create(:accreditation_type_keyword, :accreditation_type_national)
          create(:national_accreditation_type)
          described_class.run(user)
          expect(institution.accreditation_type).to eq('national')
        end
      end

      describe 'the hybrid accreditation_type' do
        it 'sets the hybrid accreditation_type' do
          create(:accreditation_type_keyword, :accreditation_type_hybrid)
          create(:hybrid_accreditation_type)
          described_class.run(user)
          expect(institution.accreditation_type).to eq('hybrid')
        end
      end

      describe 'when a keyword is in multiple accreditation_types' do
        it 'prefers national over hybrid' do
          create(:accreditation_type_keyword, :hybrid_career_schools)
          create(:accreditation_type_keyword, :accreditation_type_national)
          create(:accreditation_record, agency_name: 'Career Schools R Us')
          described_class.run(user)
          expect(institution.accreditation_type).to eq('national')
        end

        it 'prefers regional over hybrid and national' do
          create(:accreditation_type_keyword, :hybrid_career_schools)
          create(:accreditation_type_keyword, :accreditation_type_national)
          create(:accreditation_type_keyword, :regional_career_schools)

          create(:accreditation_record, agency_name: 'Career Schools R Us')
          described_class.run(user)
          expect(institution.accreditation_type).to eq('regional')
        end
      end
    end
  end
end

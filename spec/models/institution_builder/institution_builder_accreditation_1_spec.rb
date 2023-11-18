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

    describe 'when adding Accreditation data' do
      let(:institution) { institutions.find_by(ope: accreditation_institute.ope) }
      let!(:accreditation_institute) { create :accreditation_institute_campus }

      describe 'with regards to the time frame' do
        it 'only adds current accreditations' do
          create :accreditation_record
          described_class.run(user)

          expect(institution.accreditation_type).not_to be_nil
        end

        it 'does not add non-current accreditations (end date is not null)' do
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

        it 'does not add non-institutional accreditations (program id is not 1)' do
          create :accreditation_record, program_id: 2
          described_class.run(user)

          expect(institution.accreditation_type).to be_nil
        end
      end

      describe 'with regards to missing intermediate table matches' do
        it 'does not add accreditations for institutions that do not have an ope match' do
          weam = Weam.first
          # rubocop:disable Rails/SkipsModelValidations
          weam.update_columns(ope: 'junk')
          # rubocop:enable Rails/SkipsModelValidations
          create :accreditation_record
          described_class.run(user)

          institution = Institution.first
          expect(institution.accreditation_type).to be_nil
        end

        it 'does not add accreditations when there is no dapip_id match' do
          create :accreditation_record, dapip_id: -1
          described_class.run(user)

          institution = Institution.first
          expect(institution.accreditation_type).to be_nil
        end
      end
    end
  end
end

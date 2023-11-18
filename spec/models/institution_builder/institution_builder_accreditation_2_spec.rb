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
    end
  end
end

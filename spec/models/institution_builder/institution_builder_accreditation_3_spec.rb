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
          it "with a current 'restore' action, it doesn't set the accreditation_status" do
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
                              version_id: Version.current_production.id })
                     .count).to be > 0
        end

        it 'has no flags for any nil status' do
          create :accreditation_action
          described_class.run(user)

          expect(CautionFlag
                     .where({ institution_id: institution.id,
                              source: AccreditationCautionFlag::NAME,
                              version_id: Version.current_production.id })
                     .count).to eq(0)
        end

        it 'concatenates `action_description` and `justification_description`' do
          aap = create :accreditation_action_probationary

          described_class.run(user)

          caution_flags = CautionFlag.where({ institution_id: institution.id,
                                              source: AccreditationCautionFlag::NAME,
                                              version_id: Version.current_production.id }).count
          expect(caution_flags).to be > 0
          expect(institutions.find(institution.id).caution_flag_reason)
            .to include(aap.action_description, aap.justification_description)
        end
      end
    end
  end
end

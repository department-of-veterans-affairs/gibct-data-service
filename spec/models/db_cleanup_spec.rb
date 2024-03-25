# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DbCleanup, type: :model do
  describe '#delete_broken_preview' do
    # rubocop:disable RSpec/ExampleLength
    it 'removes all dependant version preview data' do
      create(:version, :preview, :with_institution_and_institution_children)

      # This seems necessary to overcome RSpec's wrapping things
      # in transactions and Postgresql does not like wrapping
      # vacuum commands in transactions. Tail the test log for why
      ActiveRecord::Base.connection.commit_db_transaction
      expect(Version.count).to eq(1)
      expect(Institution.count).to eq(1)
      expect(CautionFlag.count).to eq(1)
      expect(InstitutionProgram.count).to eq(1)
      expect(VersionedSchoolCertifyingOfficial.count).to eq(1)
      expect(YellowRibbonProgram.count).to eq(1)
      expect(ZipcodeRate.count).to eq(1)
      described_class.delete_broken_preview(Version.last.id)
      expect(Version.count).to eq(0)
      expect(Institution.count).to eq(0)
      expect(CautionFlag.count).to eq(0)
      expect(InstitutionProgram.count).to eq(0)
      expect(VersionedSchoolCertifyingOfficial.count).to eq(0)
      expect(YellowRibbonProgram.count).to eq(0)
      expect(ZipcodeRate.count).to eq(0)
    end
    # rubocop:enable RSpec/ExampleLength
  end
end

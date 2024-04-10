# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DbCleanup, type: :model do
  describe '#delete_broken_preview' do
    it 'removes all dependant version preview data' do
      version = create(:version, :preview, :with_institution_regular_address)

      # This seems necessary to overcome RSpec's wrapping things
      # in transactions and Postgresql does not like wrapping
      # vacuum commands in transactions. Tail the test log for why
      ActiveRecord::Base.connection.commit_db_transaction

      expect(Institution.count).to eq(1)
      expect(Version.count).to eq(1)
      described_class.delete_broken_preview(version.id)
      expect(Institution.count).to eq(0)
      expect(Version.count).to eq(0)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionTablesMaintenanceJob, type: :job do
  describe '#perform' do
    let(:job) { described_class.new }

    it 'writes messages to stdout' do
      # This seems necessary to overcome RSpec's wrapping things
      # in transactions and Postgresql does not like wrapping
      # vacuum commands in transactions. Tail the test log for why
      ActiveRecord::Base.connection.commit_db_transaction

      expect { job.perform }.to output(/Vacuuming/).to_stdout
    end
  end
end

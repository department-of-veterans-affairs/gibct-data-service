# frozen_string_literal: true

require 'rails_helper'

TABLES = %w[ caution_flags institution_programs versioned_school_certifying_officials
             yellow_ribbon_programs institution_category_ratings institutions
             zipcode_rates versions].freeze

RSpec.describe PerformInstitutionTablesMaintenanceJob, type: :job do
  describe '#perform' do
    let(:job) { described_class.new }

    it 'logs info level messages when it runs successfully' do
      allow(Rails.logger).to receive(:info)

      # This seems necessary to overcome RSpec's wrapping things
      # in transactions and Postgresql does not like wrapping
      # vacuum commands in transactions. Tail the test log for why
      ActiveRecord::Base.connection.commit_db_transaction

      job.perform

      TABLES.each do |table|
        expect(Rails.logger).to have_received(:info).with("Vacuuming #{table}").once
      end
    end
  end
end

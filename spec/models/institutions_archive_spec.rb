# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionsArchive, type: :model do
  let(:user) { User.first }
  let(:institutions) { Institution.version(Version.current_preview.number) }

  before(:each) do
    create :user, email: 'fred@va.gov', password: 'fuggedabodit'
  end

  describe 'archive institutions' do
    before(:each) do
      # version 1
      create_production_version
      create :institution, version: current_production_number

      # version 2
      create_production_version
      create :institution, version: current_production_number
    end

    context 'when successful' do
      it 'archives previous production version', js: true do
        # version 3
        create_production_version
        create :institution, version: current_production_number

        # version 4
        create_production_version
        create :institution, version: current_production_number

        initial_institution_count = 4
        institution_count_total = 3
        institution_count_greater_equal_production = 1
        institutions_archive_count = 1

        archive_test(initial_institution_count,
                     institution_count_total,
                     institution_count_greater_equal_production,
                     institutions_archive_count)
      end

      it 'does not archive preview versions greater than current production', js: true do
        # version 3
        create_production_version
        create :institution, version: current_production_number

        # version 4
        create_production_version
        create :institution, version: current_production_number

        # preview version 5
        create :version, :preview
        create :institution, version: current_preview_number

        initial_institution_count = 5
        institution_count_total = 4
        institution_count_greater_equal_production = 2
        institutions_archive_count = 1

        archive_test(initial_institution_count,
                     institution_count_total,
                     institution_count_greater_equal_production,
                     institutions_archive_count)
      end

      it 'archives previous production version and preview versions less than current production', js: true do
        # preview version 3
        create :version, :preview
        create :institution, version: current_preview_number

        # preview version 4
        create :version, :preview
        create :institution, version: current_preview_number

        # version 5
        create_production_version
        create :institution, version: current_production_number

        initial_institution_count = 5
        institution_count_total = 2
        institution_count_greater_equal_production = 1
        institutions_archive_count = 3

        archive_test(initial_institution_count,
                     institution_count_total,
                     institution_count_greater_equal_production,
                     institutions_archive_count)
      end
    end

    context 'when not successful' do
      it 'returns an error message' do
        error_message = 'BOOM!'
        allow(InstitutionsArchive).to receive(:create_archives).and_raise(StandardError, error_message)
        expect(Rails.logger).to receive(:error).with("There was an error of unexpected origin: #{error_message}")
        InstitutionsArchive.archive_previous_versions
      end

      it 'logs errors at the database level' do
        error_message = 'BOOM!'

        statement_invalid = ActiveRecord::StatementInvalid.new(error_message)
        statement_invalid.set_backtrace(%(backtrace))

        allow(InstitutionsArchive).to receive(:create_archives).and_raise(statement_invalid)
        expect(Rails.logger).to receive(:error)
          .with("There was an error occurring at the database level: #{error_message}")
        InstitutionsArchive.archive_previous_versions
      end
    end
  end

  # private methods
  private

  def archive_test(initial_institution_count,
                   institution_count_total,
                   institution_count_greater_equal_production,
                   institutions_archive_count)
    expect(Institution.count).to eq(initial_institution_count)
    expect(InstitutionsArchive.count).to eq(0)

    InstitutionsArchive.archive_previous_versions

    expect(Institution.count).to eq(institution_count_total)
    expect(Institution.where('version >= ?', current_production_number).size)
      .to eq(institution_count_greater_equal_production)

    expect(InstitutionsArchive.count).to eq(institutions_archive_count)
    expect(InstitutionsArchive.where('version < ?', current_production_number).size).to eq(institutions_archive_count)
  end

  def create_production_version
    create :version, :preview
    create :version, :production, number: current_preview_number
  end

  def current_preview_number
    Version.current_preview.number
  end

  def current_production_number
    Version.current_production.number
  end
end

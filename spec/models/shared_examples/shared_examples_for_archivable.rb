# frozen_string_literal: true

RSpec.shared_examples 'an archivable model' do |options|
  let(:name) { described_class.name.underscore }
  let(:factory) { options[:factory] }
  let(:original_type) { options[:original_type] }
  let(:archived_type) { described_class }
  let(:user) { User.first }

  before do
    create :user, email: 'fred@va.gov', password: 'fuggedabodit'
  end

  describe 'archives archived model' do
    before do
      # version 1
      create_production_version
      create factory, version: current_production_number

      # version 2
      create_production_version
      create factory, version: current_production_number
    end

    context 'when successful' do
      it 'archives previous production version', js: true do
        # version 3
        create_production_version
        create factory, version: current_production_number

        # version 4
        create_production_version
        create factory, version: current_production_number

        archive_test(initial_count: 4,
                     count_total: 3,
                     count_greater_equal_production: 1,
                     archive_count: 1)
      end

      it 'does not archive preview versions greater than current production', js: true do
        # version 3
        create_production_version
        create factory, version: current_production_number

        # version 4
        create_production_version
        create factory, version: current_production_number

        # preview version 5
        create :version, :preview
        create factory, version: current_preview_number

        archive_test(initial_count: 5,
                     count_total: 4,
                     count_greater_equal_production: 2,
                     archive_count: 1)
      end

      it 'archives previous production version and preview versions less than current production', js: true do
        # preview version 3
        create :version, :preview
        create factory, version: current_preview_number

        # preview version 4
        create :version, :preview
        create factory, version: current_preview_number

        # version 5
        create_production_version
        create factory, version: current_production_number

        archive_test(initial_count: 5,
                     count_total: 2,
                     count_greater_equal_production: 1,
                     archive_count: 3)
      end
    end

    context 'when not successful' do
      it 'returns an error message' do
        error_message = 'BOOM!'
        allow(Archiver).to receive(:create_archives).and_raise(StandardError, error_message)
        allow(Rails.logger).to receive(:error).with("There was an error of unexpected origin: #{error_message}")
        Archiver.archive_previous_versions
        expect(Rails.logger).to have_received(:error).with("There was an error of unexpected origin: #{error_message}")
      end

      it 'logs errors at the database level' do
        error_message = 'BOOM!'

        statement_invalid = ActiveRecord::StatementInvalid.new(error_message)
        statement_invalid.set_backtrace(%(backtrace))
        allow(Rails.logger).to receive(:error)
          .with("There was an error occurring at the database level: #{error_message}")
        allow(Archiver).to receive(:create_archives).and_raise(statement_invalid)
        Archiver.archive_previous_versions
        expect(Rails.logger).to have_received(:error)
          .with("There was an error occurring at the database level: #{error_message}")
      end
    end
  end

  private

  def archive_test(initial_count:,
                   count_total:,
                   count_greater_equal_production:,
                   archive_count:)
    expect(original_type.count).to eq(initial_count)
    expect(archived_type.count).to eq(0)

    Archiver.archive_previous_versions

    expect(original_type.count).to eq(count_total)
    expect(original_type.where('version >= ?', current_production_number).size)
      .to eq(count_greater_equal_production)

    expect(archived_type.count).to eq(archive_count)
    expect(archived_type.where('version < ?', current_production_number).size).to eq(archive_count)
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

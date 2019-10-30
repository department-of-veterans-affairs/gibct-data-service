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
      # version 2
      create_production_version
    end

    context 'when successful' do
      it 'archives previous production version', js: true do
        # version 3
        create_production_version
        # version 4
        create_production_version
        archive_test(4, 3, 1, 1)
      end

      it 'does not archive preview versions greater than current production', js: true do
        # version 3
        create_production_version
        # version 4
        create_production_version
        # preview version 5
        create_preview_version
        archive_test(5, 4, 2, 1)
      end

      it 'archives previous production version and preview versions less than current production', js: true do
        # preview version 3
        create_preview_version
        # preview version 4
        create_preview_version
        # version 5
        create_production_version
        archive_test(5, 2, 1, 3)
      end
    end

    context 'when not successful' do
      def create_invalid_statement
        error_message = 'BOOM!'
        invalid_statement = ActiveRecord::StatementInvalid.new(error_message)
        invalid_statement.set_backtrace(%(backtrace))
        allow(Archiver).to receive(:create_archives).and_raise(invalid_statement)
      end

      def check_log_for_error(error_message)
        expect(Rails.logger).to have_received(:error)
          .with(error_message)
      end
      it 'returns an error message' do
        allow(Archiver).to receive(:create_archives).and_raise(StandardError, 'BOOM!')
        allow(Rails.logger).to receive(:error).with('There was an error of unexpected origin: BOOM!')
        Archiver.archive_previous_versions
        check_log_for_error('There was an error of unexpected origin: BOOM!')
      end

      it 'logs errors at the database level' do
        create_invalid_statement
        allow(Rails.logger).to receive(:error)
          .with('There was an error occurring at the database level: BOOM!')
        Archiver.archive_previous_versions
        check_log_for_error('There was an error occurring at the database level: BOOM!')
      end
    end
  end

  private

  def archive_test(initial_count,
                   count_total,
                   count_greater_equal_production,
                   archive_count)
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
    create factory, version: current_production_number
  end

  def create_preview_version
    create :version, :preview
    create factory, version: current_preview_number
  end

  def current_preview_number
    Version.current_preview.number
  end

  def current_production_number
    Version.current_production.number
  end
end

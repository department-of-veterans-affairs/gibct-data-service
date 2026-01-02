# frozen_string_literal: true

RSpec.shared_examples 'an archivable model' do |options|
  let(:name) { described_class.name.underscore }
  let(:factory) { options[:factory] }
  let(:belongs_to_institution?) { options[:original_type].reflections.keys.include?('institution') }
  let(:original_type) do
    rel = options[:original_type]
    rel = rel.joins(:institution) if belongs_to_institution?
    rel
  end
  let(:archived_type) { described_class }
  let(:user) { User.first }

  before do
    create :user, email: 'fred@va.gov', password: 'fuggedabodit'
  end

  describe 'archives archived model' do
    before do
      # version 1
      create_version(:production)
      # version 2
      create_version(:production)
    end

    context 'when successful' do
      it 'archives previous versions', js: true do
        # version 3
        create_version(:production)
        # version 4
        create_version(:production)

        archive_test
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

  def archive_test
    before_archive_count = original_type.count

    Archiver.archive_previous_versions
    archived_count = archived_type.count
    after_archive_count = original_type.count

    expect(after_archive_count).to eq(1)
    expect(archived_count).to eq(before_archive_count - after_archive_count)
  end

  def create_version(level)
    version = create :version, level
    if belongs_to_institution?
      institution = create :institution, version: version
      create factory, institution: institution
    else
      create factory, version: version
    end
  end
end

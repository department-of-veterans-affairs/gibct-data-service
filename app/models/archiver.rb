# frozen_string_literal: true

# TODO: refactor line #6 when we write new ratings code
module Archiver
  ARCHIVE_TYPES = [
    { source: InstitutionRating, archive: InstitutionRatingsArchive },
    { source: InstitutionProgram, archive: InstitutionProgramsArchive },
    { source: VersionedSchoolCertifyingOfficial, archive: VersionedSchoolCertifyingOfficialsArchive },
    { source: ZipcodeRate, archive: ZipcodeRatesArchive },
    { source: CautionFlag, archive: nil },
    { source: Institution, archive: InstitutionsArchive },
    { source: VersionedComplaint, archive: VersionedComplaintsArchive },
    { source: CalculatorConstantVersion, archive: CalculatorConstantVersionsArchive }
  ].freeze

  def self.archive_previous_versions
    # don't bother if nothing to archive. Also note that during the initial buildout, there is no previous version
    # The below previous_version will exception out and cause all the work to be rolled back.
    return unless Version.current_production && Version.previous_production

    production_version = Version.current_production.number

    Rails.logger.info "\n\n\n*** Starting Archive process"
    Rails.logger.info 'Getting default timeout parameter'
    get_timeout_parameter

    begin
      ApplicationRecord.transaction do
        Rails.logger.info 'Inside transaction, setting local default timeout parameter'
        ActiveRecord::Base.connection.execute("SET LOCAL statement_timeout = '600000'")
        get_timeout_parameter

        ARCHIVE_TYPES.each do |archivable|
          create_archives(archivable[:source], archivable[:archive], production_version)
          source = if archivable[:source].has_attribute?(:institution_id)
                     archivable[:source].joins(institution: :version)
                   else
                     archivable[:source].joins(:version)
                   end

          source.where('number < ?', production_version).in_batches.delete_all
        end
      end
    rescue ActiveRecord::StatementInvalid => e
      notice = 'There was an error occurring at the database level'
      process_exception(notice, e, production_version)
    rescue StandardError => e
      notice = 'There was an error of unexpected origin'
      process_exception(notice, e, production_version)
    end

    Rails.logger.info 'Done archiving, getting default timeout parameter'
    get_timeout_parameter
    Rails.logger.info "*** End of Archiving process\n\n\n"
  end

  def self.create_archives(source, archive, production_version)
    return if archive.blank?

    Rails.logger.info "\n\n\n*** Archiving #{source.table_name}"
    PreviewGenerationStatusInformation.create!(current_progress: "archiving #{source.table_name}")

    base_query = build_archive_query(source, production_version)
    Rails.logger.info "base query: #{base_query}"
    Rails.logger.info "query as sql: #{base_query.to_sql}"
    archive_columns = archive.column_names

    base_query.find_in_batches(batch_size: 1000) do |records|
      attributes = records.map { |record| record.attributes.slice(*archive_columns) }
      # rubocop:disable Rails/SkipsModelValidations
      archive.insert_all(attributes) if attributes.present?
      # rubocop:enable Rails/SkipsModelValidations
    end
    Rails.logger.info "*** Done archiving #{source.table_name}"
  end

  def self.build_archive_query(source, production_version)
    if source.has_attribute?(:institution_id)
      source
        .joins(institution: :version)
        .where(institutions: { approved: true })
        .where('versions.number < ?', production_version)
    elsif source.eql?(Institution)
      source
        .joins(:version)
        .where(approved: true)
        .where('versions.number < ?', production_version)
    else
      source
        .joins(:version)
        .where('versions.number < ?', production_version)
    end
  end

  def self.process_exception(notice, exception, production_version)
    Raven.extra_context(production_version: production_version)
    Raven.capture_exception(exception) if ENV['SENTRY_DSN'].present?
    Rails.logger.error "#{notice}: #{exception.message}"
  end

  def self.get_timeout_parameter
    get_timeout_sql = "select setting from pg_settings where name = 'statement_timeout'"
    timeout_result = ActiveRecord::Base.connection.execute(get_timeout_sql).first
    Rails.logger.info "timeout parameter is currently: #{timeout_result['setting']}"
  end
end

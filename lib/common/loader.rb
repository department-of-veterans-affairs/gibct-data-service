# frozen_string_literal: true

module Common
  module Loader
    # Results is an Array of ImportableRecords
    def load(results, options = {}, async_options)
      klass.transaction do
        delete_all
        load_records(results, options, async_options)
      end
    end

    # Checks if there are any current transactions wrapping this method call
    # If not calls this classes default load with the provided Array of ImportableRecords
    def load_records(records, options, async_options)
      return load(records, options, async_options) if klass.connection.open_transactions.zero?

      total_results = ActiveRecord::Import::Result.new([], 0, [], [])
      total_failed_instances = []

      if async_options[:enabled]
        @upload = Upload.find_by(id: async_options[:upload_id]) 
        completed_count = 0
      end

      records.each_slice(Settings.active_record.batch_size.import) do |batch|
        results = klass.import batch, ignore: true
        @upload&.tap do |u|
          completed_count += batch.size
          u.update_import_progress!(completed_count, records.size)
        end
        total_failed_instances.concat results&.failed_instances
        total_results.failed_instances.concat results&.failed_instances
        total_results.num_inserts += results&.num_inserts
        total_results.ids.concat results&.ids
        total_results.results.concat results&.results
      end

      after_import_validations(records, total_failed_instances, options)

      total_results
    end

    private

    # Default validations are run during import, which prevent bad data from being persisted to the database.
    # This method manually runs validations that were declared with a specific validation context (:after_import).
    # Or runs "#{klass.name}Validator" method after_import_batch_validations for large import files
    #
    # If using either method the weams.csv_row column should be populated with a meaningful value and a :first_line
    # value should be in the options object if the default of zero is not sufficient
    #
    # The result is warnings are generated for the end user while the data is allowed to persist to the database.
    def after_import_validations(records, failed_instances, options)
      return if run_after_import_batch_validations?(failed_instances)

      records.each_with_index do |record, index|
        next if record.valid?(:after_import)

        csv_row_number = document_row(index, options)
        record.errors.add(:row, csv_row_number)
        failed_instances << record if record.persisted?
      end
    end

    def run_after_import_batch_validations?(failed_instances)
      # this is a call to custom batch validation checks for large import CSVs
      validator_klass = "#{klass.name}Validator".safe_constantize
      run_validations = validator_klass.present? && defined? validator_klass.after_import_batch_validations

      if run_validations
        failed_instances.each do |record|
          record.errors.add(:row, record.csv_row)
        end
        validator_klass.after_import_batch_validations(failed_instances)
      end
      run_validations
    end

    def row_offset(options)
      (options[:first_line] || 0) + (options[:skip_lines] || 0)
    end

    # actual row in document for use by user
    def document_row(index, options)
      index + row_offset(options)
    end
  end
end

# frozen_string_literal: true

# Shared behavior between sync and async upload creation
class UploadFileProcessor
  def initialize(upload)
    @upload = upload
  end

  def load_file
    return unless @upload.persisted?

    file = file_from_blob || @upload.upload_file.tempfile

    CrosswalkIssue.delete_all if [Crosswalk, IpedsHd, Weam].include?(klass)

    # first is used because when called from standard upload process
    # because only a single set of results is returned
    file_options = { liberal_parsing: @upload.liberal_parsing,
                     sheets: [{ klass: klass, skip_lines: @upload.skip_lines.try(:to_i) || 0,
                                clean_rows: @upload.clean_rows,
                                multiple_files: @upload.multiple_file_upload }] }
    file_options.merge!(async: { enabled: true, upload_id: @upload.id }) if @upload.async_enabled?
    data = klass.load_with_roo(file, file_options).first

    CrosswalkIssue.rebuild if [Crosswalk, IpedsHd, Weam].include?(klass)

    data
  end

  def self.parse_results(data)
    return if data.empty?

    results = data[:results]
    failed_rows = results.failed_instances
    validation_warnings = failed_rows.sort do |a, b|
      a.errors[:row].first.to_i <=> b.errors[:row].first.to_i
    end.map(&:display_errors_with_row)
                 
    {
      total_rows_count: results.ids.length,
      failed_rows_count: failed_rows.length,
      validation_warnings: validation_warnings,
      header_warnings: data[:header_warnings]
    }.tap do |hash|
        hash[:valid_rows] = hash[:total_rows_count] - hash[:failed_rows_count]
    end
  end

  private

  def klass
    @upload.csv_type.constantize
  end

  # Create tempfile from reassmbled blob
  def file_from_blob
    return unless @upload.blob

    Tempfile.new([klass.name, '.txt'], binmode: true).tap do |file|
      file.write(@upload.blob)
      file.rewind
      # Final blob too large to permanently persist in DB
      @upload.update(blob: nil)
    end
  end
end

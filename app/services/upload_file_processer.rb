# frozen_string_literal: true

class UploadFileProcesser
  def initialize(upload)
    @upload = upload
  end

  def load_file
    file = file_from_blob || @upload.upload_file.tempfile

    CrosswalkIssue.delete_all if [Crosswalk, IpedsHd, Weam].include?(klass)
  
    # first is used because when called from standard upload process
    # because only a single set of results is returned
    file_options = { liberal_parsing: @upload.liberal_parsing,
                     sheets: [{ klass: klass, skip_lines: @upload.skip_lines.try(:to_i),
                                clean_rows: @upload.clean_rows,
                                multiple_files: @upload.multiple_file_upload }] }
    data = klass.load_with_roo(file, file_options).first
  
    CrosswalkIssue.rebuild if [Crosswalk, IpedsHd, Weam].include?(klass)
  
    data
  end

  private

  def klass
    @upload.csv_type.constantize
  end

  def file_from_blob
    Tempfile.new([klass, "txt"], binmode: true).tap do |file|
      file.write(@upload.blob)
      file.rewind
    end
  end
end

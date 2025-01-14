# frozen_string_literal: true

class ProcessUploadJob < ApplicationJob
  queue_as :default

  def perform(upload)
    @upload = upload
    begin
      data = UploadFileProcesser.new(@upload).load_file
      # alert_messages(data)
      data_results = data[:results]

      @upload.update(ok: data_results.present? && data_results.ids.present?, completed_at: Time.now.utc.to_fs(:db))
      error_msg = "There was no saved #{klass} data. Please check the file or \"Skip lines before header\"."
      raise(StandardError, error_msg) unless @upload.ok?
    rescue StandardError => e
      byebug
    ensure
      @upload.update(blob: nil, status_message: nil)
    end
  end

  private

  def klass
    @upload.csv_type.constantize
  end
end

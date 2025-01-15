# frozen_string_literal: true

class ProcessUploadJob < ApplicationJob
  queue_as :default

  def perform(upload)
    @upload = upload
    raise StandardError,"Upload canceled" if @upload.canceled_at
    @upload.update(status_message: "processing data . . .")
    begin
      data = UploadFileProcesser.new(@upload).load_file
      # alert_messages(data)
      data_results = data[:results]

      @upload.update(ok: data_results.present? && data_results.ids.present?, completed_at: Time.now.utc.to_fs(:db))
      error_msg = "There was no saved #{klass} data. Please check the file or \"Skip lines before header\"."
      raise(StandardError, error_msg) unless @upload.ok?
    rescue StandardError => e
      @upload.cancel!
      Rails.logger.error(e.message + e.backtrace.to_s)
    else
      @upload.clean!
    end
  end

  private

  def klass
    @upload.csv_type.constantize
  end
end

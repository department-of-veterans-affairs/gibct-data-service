# frozen_string_literal: true

class ProcessUploadJob < ApplicationJob
  queue_as :default

  def perform(upload)
    @upload = upload
    begin
      @upload.safely_update_status!("preparing upload . . .")
      data = UploadFileProcessor.new(@upload).load_file
      save_alert_messages(data)
      puts("JEFF: after save alert message")
      puts("status: " + @upload.status_message)
      puts("completed at: " + @upload.completed_at.to_s)
      data_results = data[:results]

      @upload.update(ok: data_results.present? && data_results.ids.present?, completed_at: Time.now.utc.to_fs(:db))
      error_msg = "There was no saved #{klass} data. Please check the file or \"Skip lines before header\"."
      raise(StandardError, error_msg) unless @upload.ok?
    rescue StandardError => e
      @upload.cancel!
      Rails.logger.error(e.message + e.backtrace.to_s)
    end
  end

  private

  def klass
    @upload.csv_type.constantize
  end

  def save_alert_messages(data)
    results_breakdown = UploadFileProcessor.parse_results(data)
    results_breakdown => { valid_rows:,
                          total_rows_count:,
                          failed_rows_count:,
                          header_warnings:, 
                          validation_warnings:}
    alerts = {}

    if valid_rows.positive?
      alerts[:csv_success] = {
        total_rows_count: total_rows_count.to_s,
        valid_rows: valid_rows.to_s,
        failed_rows_count: failed_rows_count.to_s
      }.compact
    end

    alerts[:warning] = {
      'The following headers should be checked: ': (header_warnings unless header_warnings.empty?),
      'The following rows should be checked: ': (validation_warnings unless validation_warnings.empty?)
    }.compact

    @upload.update!(status_message: alerts.to_json)
  end
end

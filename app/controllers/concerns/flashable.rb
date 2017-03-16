# frozen_string_literal: true
module Flashable
  extend ActiveSupport::Concern

  def message_for_notice(invalid_records)
    msg = "Uploading #{upload_params[:csv_type]} succeeded"
    msg + (invalid_records.present? ? ' with warnings:' : '.')
  end

  def errors_for_alert(invalid_records)
    error_list = invalid_records[0, 15].map do |record|
      line = record.errors.delete(:base)
      line = line.try(:first) || line
      (line ? "#{line}: " : '') + record.errors.map { |col, msg| "#{col}: #{msg}" }.join(', ')
    end

    remaining = invalid_records.length - 15
    error_list << "Plus #{remaining} #{'warning'.pluralize(remaining)} not listed ..." if remaining.positive?

    error_list
  end
end

# frozen_string_literal: true
module Flashable
  extend ActiveSupport::Concern

  def alerts
    @alerts ||= {}
  end

  def notices
    @notices ||= {}
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

  def add_alerts(label, errors, backtrace = nil)
    alerts[label] = errors

    log_message(label, errors, backtrace)
  end

  def add_notices(label, errors)
    notices[label] = errors

    log_message(label, errors)
  end

  def log_message(msg, errors, backtrace = nil)
    return if msg.blank?

    Rails.logger.error(msg)
    Rails.logger.error(errors.join("\n"))
    Rails.logger.error(backtrace.join("\n")) if backtrace.present?
  end

  def set_flash
    flash.alert = alerts
    flash.notice = notices
  end
end

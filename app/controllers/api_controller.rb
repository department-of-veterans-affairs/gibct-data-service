# frozen_string_literal: true

class ApiController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :resolve_version

  def cors_preflight
    head(:ok)
  end

  private

  # :nocov:
  def page
    Integer(params[:page] || '1')
  rescue ArgumentError
    1
  end

  def float_conversion(val)
    Float(val)
  rescue ArgumentError
    nil
  end
  # :nocov:

  # Newest production data version assumed when version param is undefined
  def resolve_version
    v = params[:version]
    @version = (v.present? && Version.find_by(uuid: v)) || Version.current_production

    raise Common::Exceptions::Internal::InvalidFieldValue, "Version #{v} not found" unless @version.try(:number)
  end

  def self_link
    URI.join(Figaro.env.link_host, request.original_fullpath).to_s
  end

  rescue_from 'Exception' do |exception|
    log_error(exception)

    va_exception =
      case exception
      when ActionController::ParameterMissing
        Common::Exceptions::Internal::ParameterMissing.new(exception.param)
      when Common::Exceptions::BaseError
        exception
      else
        Common::Exceptions::Internal::InternalServerError.new(exception)
      end

    if va_exception.is_a?(Common::Exceptions::Internal::Unauthorized)
      headers['WWW-Authenticate'] = 'Token realm="Application"'
    end
    render json: { errors: va_exception.errors }, status: va_exception.status_code
  end

  def log_error(exception)
    Raven.capture_exception(exception) if ENV['SENTRY_DSN'].present?
    Rails.logger.error "#{exception.message}."
    Rails.logger.error exception.backtrace.join("\n") unless exception.backtrace.nil?
  end
end

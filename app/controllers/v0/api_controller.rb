# frozen_string_literal: true
module V0
  class ApiController < ApplicationController
    skip_before_action :authenticate_user!

    def cors_preflight
      head(:ok)
    end

    private

    rescue_from 'Exception' do |exception|
      log_error(exception)

      va_exception =
        case exception
        when ActionController::ParameterMissing
          Common::Exceptions::ParameterMissing.new(exception.param)
        when Common::Exceptions::BaseError
          exception
        else
          Common::Exceptions::InternalServerError.new(exception)
        end

      if va_exception.is_a?(Common::Exceptions::Unauthorized)
        headers['WWW-Authenticate'] = 'Token realm="Application"'
      end
      render json: { errors: va_exception.errors }, status: va_exception.status_code
    end

    def log_error(exception)
      Rails.logger.error "#{exception.message}."
      Rails.logger.error exception.backtrace.join("\n") unless exception.backtrace.nil?
    end
  end
end

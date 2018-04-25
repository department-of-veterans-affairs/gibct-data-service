# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Cause authentication before every action.
  before_action :authenticate_user!, except: :home
  before_action :session_expiry
  before_action :set_cache_headers

  def home
    if current_user
      redirect_to dashboards_path
    else
      redirect_to new_user_session_path
    end
  end

  SESSION_DURATION = 7.days

  # TODO
  # reset session on login to avoid session fixation
  # do session.any? to avoid unloaded session (see devise code)
  # Implement logout in auth controller
  # Implement static "logged out" page with redirect to login path

  def session_expiry
    return unless session[:user_id]
    session_model = ActiveRecord::SessionStore::Session.find_by(session_id: session.id)
    if session_model.updated_at + 10.minutes < Time.current
      Rails.logger.info('Expiring!')
      session[:user_id] = nil
      flash.alert = 'Your session expired. Please sign in again to continue.'
      redirect_to root_path
    end
    session_model.touch
  end

  # Overriding the devise sign_out path
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def set_cache_headers
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 1.year.ago.to_s
  end
end

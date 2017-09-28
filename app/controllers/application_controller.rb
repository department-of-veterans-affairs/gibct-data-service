# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Cause authentication before every action.
  before_action :authenticate_user!
  before_action :session_expiry
  before_action :debug_session
  #before_action :authenticate
  #after_action :debug_post_session

  def _current_user
    return unless session[:user_id]
    @current_user ||= User.find_by(email: session[:user_id])
  end

  SESSION_DURATION = 7.days

  # TODO
  # reset session on login to avoid session fixation
  # do session.any? to avoid unloaded session (see devise code)
  # Implement logout in auth controller
  # Implement static "logged out" page with redirect to login path

  def session_expiry
    #return unless session[:user_id]
    session_model = ActiveRecord::SessionStore::Session.find_by(session_id: session.id)
    if session_model.updated_at + 10.minutes < Time.now
      puts "Expiring!"
      session[:user_id] = nil
      redirect_to saml_login_path
    end
    session_model.touch
  end

  def authenticate
    redirect_to saml_login_path unless session[:user_id]
  end

  def debug_session
    puts session
    #puts session.attributes
    session.keys.each { |k| puts "#{k}: #{session[k]}" }
    puts session.id
    s = ActiveRecord::SessionStore::Session.find_by(session_id: session.id)
    puts s.inspect
    puts s.updated_at if s.present?
  end

  def debug_post_session
    puts session.inspect
  end

end

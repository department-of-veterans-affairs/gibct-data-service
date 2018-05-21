# frozen_string_literal: true
require 'saml/settings'

class AuthController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def new
    request = OneLogin::RubySaml::Authrequest.new
    redirect_to(request.create(saml_settings))
  end

  def callback
    response = OneLogin::RubySaml::Response.new(params[:SAMLResponse],
                                                settings: saml_settings)
    if response.is_valid?
      user = User.from_saml_callback(response.attributes)
      if user
        sign_in_and_redirect user
      else
        Rails.logger.info("Email: #{response.attributes[:va_eauth_emailaddress].downcase} is not in GIDS")
        flash.alert = 'User does not have a valid GIDS system account. ' \
                      'Contact the system admin for further assistance.'
        redirect_to root_url + '?auth=fail'
      end
    else
      flash.alert = 'Authentication failed. Please try again'
      redirect_to root_url + '?auth=fail'
    end
  end

  def metadata
    meta = OneLogin::RubySaml::Metadata.new
    render xml: meta.generate(saml_settings), content_type: 'application/samlmetadata+xml'
  end

  def saml_settings
    @settings ||= SAML::Settings.settings
  end
end

# frozen_string_literal: true

module SAML
  class Settings
    class << self
      def settings
        idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
        result = idp_metadata_parser.parse(File.read(ENV['SAML_IDP_METADATA_FILE']))
        result.assertion_consumer_service_url = ENV['SAML_CALLBACK_URL']
        result.idp_sso_target_url = ENV['SAML_IDP_SSO_URL']
        result.issuer = ENV['SAML_ISSUER']
        result.private_key = File.read(File.expand_path(ENV['SAML_KEY_PATH']))
        result.certificate = File.read(File.expand_path(ENV['SAML_CERT_PATH']))
        result.security[:want_assertions_signed] = true
        result.security[:want_assertions_encrypted] = true
        result
      end
    end
  end
end

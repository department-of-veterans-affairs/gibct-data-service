module SAML
  class Settings
    class << self
      def settings
        idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
        result = idp_metadata_parser.parse(ENV['SAML_IDP_METADATA_FILE'])
        result.assertion_consumer_service_url = ENV['SAML_CALLBACK_URL']
        result.idp_sso_target_url = ENV['SAML_IDP_SSO_URL']
        result.issuer = ENV['SAML_ISSUER']
        result
      end
    end
  end
end

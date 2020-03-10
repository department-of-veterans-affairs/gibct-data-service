# frozen_string_literal: true

Figaro.require_keys(
  'LINK_HOST',
  'SECRET_KEY_BASE',
  'GIBCT_URL',
  'SAML_IDP_METADATA_FILE',
  'SAML_CALLBACK_URL',
  'SAML_IDP_SSO_URL',
  'SAML_ISSUER',
  'GOVDELIVERY_URL',
  'GOVDELIVERY_TOKEN',
  'GOVDELIVERY_STAGING_SERVICE',
  'DEPLOYMENT_ENV',
)

unless %w(vagov-dev vagov-staging vagov-prod).include?(ENV.fetch('DEPLOYMENT_ENV'))
  raise ENV.fetch('DEPLOYMENT_ENV') + " is not a valid DEPLOYMENT_ENV value"
end
require 'common/exceptions'

Rails.application.config.after_initialize do
  deployment_env = ENV.fetch('DEPLOYMENT_ENV')
  unless %w(vagov-dev vagov-staging vagov-prod).include?(deployment_env)
    raise deployment_env + " is not a valid DEPLOYMENT_ENV value. Expected vagov-dev, vagov-staging or vagov-prod"
  end
end

def development?
  Settings.environment === 'vagov-dev'
end

def staging?
  Settings.environment === 'vagov-staging'
end

def production?
  Settings.environment === 'vagov-prod'
end

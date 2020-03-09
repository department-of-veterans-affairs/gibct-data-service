require 'common/exceptions'

def development?
  Settings.environment === 'vagov-dev'
end

def staging?
  Settings.environment === 'vagov-staging'
end

def production?
  Settings.environment === 'vagov-prod'
end

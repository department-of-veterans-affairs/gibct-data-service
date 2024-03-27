# Load the Rails application.
require_relative 'application'

# get rid of annoying field_with_errors wrapper
# https://coderwall.com/p/s-zwrg/remove-rails-field_with_errors-wrapper
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  html_tag.html_safe
end

# Initialize the Rails application.
Rails.application.initialize!

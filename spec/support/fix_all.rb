# frozen_string_literal: true

# Unfortunately there is a conflict between RSpec's all and Capybara's all
# see https://github.com/jnicklas/capybara/issues/1396.
# The all that you are calling is actually Capybara's all.
# See https://stackoverflow.com/a/25903872/1669481
module FixAll
  def all(expected)
    RSpec::Matchers::BuiltIn::All.new(expected)
  end
end

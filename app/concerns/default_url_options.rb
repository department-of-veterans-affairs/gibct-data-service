# frozen_string_literal: true

module DefaultUrlOptions
  def default_url_options
    Rails.application.config.action_mailer.default_url_options
  end
end

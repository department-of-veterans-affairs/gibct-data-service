protocol, host = Figaro.env.link_host!.split('://')
Rails.application.routes.default_url_options = { protocol: protocol, host: host }

protocol, home_url = Figaro.env.gibct_url!.split('://')
host = home_url.split('/').first
Rails.application.config.action_mailer.default_url_options = { protocol: protocol, host: host }

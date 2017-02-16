protocol, host = Figaro.env.link_host!.split('://')
Rails.application.routes.default_url_options = { protocol: protocol, host: host }

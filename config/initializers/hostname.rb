protocol, host = Settings.links.host.split('://')
Rails.application.routes.default_url_options = { protocol: protocol, host: host }

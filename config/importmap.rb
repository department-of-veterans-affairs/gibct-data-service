# Pin npm packages by running ./bin/importmap

# Important! In application.html.erb, we must hard code script and links tags that reference assets pinned by
#            importmap. Otherwise we're unable to include nonce attribute, which violates CSP. When a new
#            asset is pinned, don't forget to update application.html.erb.

# main.js instead of application.js to avoid name-collision with legacy app/assets/javascripts/application.js
pin "main", to: "main.js", preload: true
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/stimulus-loading", to: "@hotwired--stimulus-loading.js"
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js" # @8.0.16
pin "@hotwired/turbo", to: "@hotwired--turbo.js" # @8.0.13
pin "@rails/actioncable/src", to: "@rails--actioncable--src.js" # @8.0.200

pin_all_from "app/javascript/controllers", under: "controllers"

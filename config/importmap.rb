# Pin npm packages by running ./bin/importmap

# main.js instead of application.js to avoid name-collision with legacy app/assets/javascripts/application.js
pin "main", to: "main.js", preload: true
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

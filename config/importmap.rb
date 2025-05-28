# Pin npm packages by running ./bin/importmap

# main.js instead of application.js to avoid name-collision with legacy app/assets/javascripts/application.js
pin "main"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin_all_from "app/javascript/controllers", under: "controllers"

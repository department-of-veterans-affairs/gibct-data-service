// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// Renamed from application.js to main.js to avoid name collision with legacy app/assets/javascripts/application.js

import { Application } from "@hotwired/stimulus";
import "@hotwired/turbo-rails"

window.Stimulus = Application.start();

// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// Renamed from application.js to main.js to avoid name collision with legacy app/assets/javascripts/application.js

import { Application } from "@hotwired/stimulus";
import "@hotwired/turbo-rails"
import RatesFormController from "./controllers/rates_form_controller";
import ConstantsFormController from "./controllers/constants_form_controller";
import ApplyRatesModalController from "./controllers/apply_rates_modal_controller";

window.Stimulus = Application.start();
Stimulus.register("rates-form", RatesFormController);
Stimulus.register("constants-form", ConstantsFormController);
Stimulus.register("apply-rates-modal", ApplyRatesModalController);

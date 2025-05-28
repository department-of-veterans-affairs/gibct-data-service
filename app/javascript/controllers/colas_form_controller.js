import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "input", "editButton", "saveAndCancelButtons" ];

  enableEditing() {
    // enable input fields for cola rates
    for (const target of this.inputTargets) {
      target.disabled = false;
    };

    // swap edit button for save/cancel buttons
    this.editButtonTarget.style.display = "none";
    this.saveAndCancelButtonsTarget.style.display = "inline-block";
  }
}

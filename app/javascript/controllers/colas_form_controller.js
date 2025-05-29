import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "input", "editButton", "updateButton", "heading" ];

  static BLUE = "rgb(243, 243, 255)";
  static GRAY = "rgb(245, 245, 245)";

  connect() {
    // save original input values so #cancel can revert changes without calling server
    this.originalInputs = {};
    this.inputTargets.forEach(input => {
      this.originalInputs[input.name] = input.value;
    });
  }

  toggleForm() {
    this.#toggle_inputs();
    this.#toggle_buttons();
    this.#toggle_heading();
  }

  cancel() {
    // reset inputs to original values
    this.inputTargets.forEach(input => {
      if (input.name in this.originalInputs) {
        input.value = this.originalInputs[input.name];
      }
    });

    this.toggleForm();
  }

  // toggle edit button on and save/cancel off, and vice versa
  #toggle_buttons() {
    const isEditing = this.editButtonTarget.disabled === true;

    this.editButtonTarget.disabled = !isEditing;
    this.updateButtonTargets.forEach(button => {
      button.disabled = isEditing;
    });
  }

  // toggle input fields enabled/disabled
  #toggle_inputs() {
    this.inputTargets.forEach(input => {
      input.disabled = !input.disabled;
    });
  }

  #toggle_heading() {
    const { BLUE, GRAY } = this.constructor;
    const isBlue = this.headingTarget.style.backgroundColor === BLUE
    this.headingTarget.style.backgroundColor = isBlue? GRAY : BLUE;
  }
}

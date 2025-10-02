import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "input", "editButton", "updateButton", "heading", "warning", "rateOption" ];

  static BLUE = "rgb(243, 243, 255)";
  static GRAY = "rgb(245, 245, 245)";

  connect() {
    this.#reset();
    this.isEditing = false;
    // Save original input values so #cancel can revert changes without calling server
    this.originalInputs = {};
    // Save rates selected for deletion before changes are committed
    this.softDeletedRates = [];
    this.inputTargets.forEach(input => {
      this.originalInputs[input.name] = input.value;
    });
  }

  cancel() {
    // Reset inputs to original values
    this.inputTargets.forEach(input => {
      if (input.name in this.originalInputs) {
        input.value = this.originalInputs[input.name];
      }
    });
    // Reset soft deleted rates
    this.softDeletedRates.forEach(rateDiv => {
      rateDiv.style.display = "flex";
      rateDiv.querySelector('input[data-marked-for-destroy]').remove();
    });
    this.softDeletedRates = [];
    this.toggleForm();
  }

  afterSubmit() {
    this.toggleForm();
    this.#cleanConstantsTable();
  }
  
  toggleForm() {
    this.isEditing = !this.isEditing
    if (this.hasWarningTarget) {
      this.warningTarget.hidden = true
    }
    this.#toggleInputs();
    this.#toggleButtons();
    this.#toggleHeading();
  }

  // Remove rate from DOM but don't commit change until save selected
  softDelete(event) {
    event.preventDefault();
    const rateDiv = event.currentTarget.closest('.rate-div');
    this.softDeletedRates.push(rateDiv);
    rateDiv.style.display = "none";
    this.#markForDestroy(rateDiv);
    const spans = rateDiv.querySelectorAll("span");
    this.#toggleSpans(spans);
  }

  toggleDelete(event) {
    // Necessary to ignore focusout when clicking delete button
    if (event.type === "focusout" && event.relatedTarget?.closest('.rate-delete')) {
      return;
    }
    const spans = event.currentTarget.closest('.rate-div').querySelectorAll("span");
    this.#toggleSpans(spans);
  }

  // Prevent CRUD actions to Calculator Constants if rates form still in edit mode
  warn(event) {
    if (this.isEditing) {
      event.preventDefault();
      event.stopImmediatePropagation()
      this.warningTarget.removeAttribute("hidden");
    }
  }

  #reset() {
    if (this.editButtonTarget.disabled === true) {
      this.toggleForm();
    }
  }

  // Toggle edit button on and save/cancel off, and vice versa
  #toggleButtons() {
    this.editButtonTarget.disabled = !this.editButtonTarget.disabled;
    this.updateButtonTargets.forEach(button => {
      button.disabled = !button.disabled
    });
  }

  // Toggle input fields enabled/disabled
  #toggleInputs() {
    this.inputTargets.forEach(input => {
      input.disabled = !input.disabled;
    });
  }

  #toggleHeading() {
    const { BLUE, GRAY } = this.constructor;
    const isBlue = this.headingTarget.style.backgroundColor === BLUE
    this.headingTarget.style.backgroundColor = isBlue? GRAY : BLUE;
  }

  #toggleSpans(spans) {
    spans.forEach(span => {
      const currentStyle = span.style.display;
      span.style.display = currentStyle === "none" ? "block" : "none";
    });
  }

  #markForDestroy(rateDiv) {
    const hiddenInput = document.createElement('input');
    hiddenInput.type = 'hidden';
    hiddenInput.name = 'marked_for_destroy[]';
    hiddenInput.value = rateDiv.dataset.rateId;
    hiddenInput.dataset.markedForDestroy = "true";
    rateDiv.appendChild(hiddenInput);
  }

  #cleanConstantsTable() {
    this.softDeletedRates.forEach((rateDiv) => {
      const rateId = rateDiv.dataset.rateId;
      this.rateOptionTargets.forEach(opt => {
        if (opt.value === rateId) {
          opt.remove();
        }
      })
    });
    this.softDeletedRates = [];
  }
}

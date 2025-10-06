import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "input", "editButton", "updateButton", "heading", "warning", "rateOption",
                     "addRemoveButton", "percent", "ex", "newRate", "newRateInput", "rateTemplate",
                      "ratesList" ];

  static BLUE = "rgb(243, 243, 255)";
  static GRAY = "rgb(245, 245, 245)";

  connect() {
    this.#reset();
    this.isEditing = false;
    // Save original input values so #cancel can revert changes without calling server
    this.originalInputs = {};
    // Save rates selected for deletion/creation before changes are committed
    this.softDeletedRates = [];
    this.softCreatedRates = [];
    this.createdRatesCounter = 0;
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
    // Toggle add/remove button if necessary
    if (this.isAddingRemoving) {
      this.toggleAddRemove();
    }
  }

  afterSubmit() {
    this.toggleForm();
    // Toggle add/remove button if necessary
    if (this.isAddingRemoving) {
      this.toggleAddRemove();
    }
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

  // Remove rate from DOM but don't commit change until form submitted
  softDelete(event) {
    event.preventDefault();
    const rateDiv = event.currentTarget.closest('.rate-div');
    this.softDeletedRates.push(rateDiv);
    rateDiv.style.display = "none";
    // Create hidden input on rate-div to mark for destroy by backend
    const hiddenInput = document.createElement('input');
    hiddenInput.type = 'hidden';
    hiddenInput.name = 'marked_for_destroy[]';
    hiddenInput.value = rateDiv.dataset.rateId;
    hiddenInput.dataset.markedForDestroy = "true";
    rateDiv.appendChild(hiddenInput);
  }

  // Add rate to DOM but don't commit change until form submitted
  softCreate(event) {
    event.preventDefault();
    // Clone div from template
    const rateDiv = this.rateTemplateTarget.cloneNode(true);
    rateDiv.removeAttribute("data-rates-form-target");
    this.softCreatedRates.push(rateDiv);
    rateDiv.hidden = false;
    const input = rateDiv.querySelector("input");
    // Generate unique ID
    this.createdRatesCounter++;
    input.id = `new_rate_${this.createdRatesCounter}`;
    input.name = `rate_adjustments[${input.id}][rate]`;
    const label = rateDiv.querySelector("label");
    const benefitType = this.newRateInputTarget.value;
    label.textContent = `Ch. ${benefitType}`;
    label.setAttribute("for", input.id);
    this.ratesListTarget.appendChild(rateDiv);
    // Create hidden input on rate-div to mark for creation by backend
    const hiddenInput = document.createElement('input');
    hiddenInput.type = 'hidden';
    hiddenInput.name = 'marked_for_create[]';
    hiddenInput.value = input.id;
    hiddenInput.dataset.markedForCreate = "true";
    rateDiv.appendChild(hiddenInput);

    const benefitTypeInput = document.createElement('input');
    benefitTypeInput.type = 'hidden';
    benefitTypeInput.name = `rate_adjustments[${input.id}][benefit_type]`;
    benefitTypeInput.value = benefitType;
    rateDiv.appendChild(benefitTypeInput);
  }

  toggleAddRemove() {
    this.isAddingRemoving = true;
    this.percentTargets.forEach(el => this.#toggleHiddenElement(el));
    this.exTargets.forEach(el => this.#toggleHiddenElement(el));
    this.#toggleHiddenElement(this.newRateTarget);
    this.#toggleDisabledElement(this.addRemoveButtonTarget);
  }

  // Prevent CRUD actions to Calculator Constants if rates form still in edit mode
  warn(event) {
    if (this.isEditing) {
      event.preventDefault();
      event.stopImmediatePropagation();
      this.warningTarget.hidden = false;
    }
  }

  #reset() {
    if (this.editButtonTarget.disabled === true) {
      this.toggleForm();
    }
  }

  #toggleButtons() {
    this.#toggleDisabledElement(this.editButtonTarget);
    this.updateButtonTargets.forEach(button => this.#toggleDisabledElement(button));
    this.#toggleHiddenElement(this.addRemoveButtonTarget);
  }

  #toggleInputs() {
    this.inputTargets.forEach(input => this.#toggleDisabledElement(input));
  }

  #toggleDisabledElement(el) {
    el.disabled = !el.disabled;
  }

  #toggleHiddenElement(el) {
    el.hidden = !el.hidden;
  }

  #toggleHeading() {
    const { BLUE, GRAY } = this.constructor;
    const isBlue = this.headingTarget.style.backgroundColor === BLUE
    this.headingTarget.style.backgroundColor = isBlue? GRAY : BLUE;
  }

  // If rates deletes, remove as option from select dropdown in constants table
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

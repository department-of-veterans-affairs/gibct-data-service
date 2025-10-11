import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "input", "editButton", "updateButton", "heading", "warning", "chapterInput",
                     "footer", "percent", "ex", "newRateForm", "addRemoveButton", "newRate",
                     "rateDiv", "form" ];

  static BLUE = "rgb(243, 243, 255)";
  static GRAY = "rgb(245, 245, 245)";

  connect() {
    // Save original input values so #cancel can revert changes without calling server
    this.originalInputs = {};
    // Save rates selected for deletion before changes are committed
    this.softDeletedRates = [];
    // Track benefit types to validate uniqueness
    this.benefitTypes = this.rateDivTargets.map(el => el.dataset.benefitType);
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
    // Clear soft created rates
    this.newRateTargets.forEach(el => el.remove());
    this.toggleForm();
    // Toggle add/remove button if necessary
    if (this.isAddingRemoving) this.toggleAddRemove();
    if (this.#isWarning()) this.#toggleHiddenElement(this.warningTarget);
  }
  
  toggleForm() {
    this.#toggleEditState();
    this.#disableEachElement(this.inputTargets);
    this.#toggleDisabledElement(this.editButtonTarget);
    this.#disableEachElement(this.updateButtonTargets);
    this.#toggleHiddenElement(this.footerTarget);
    this.#toggleHeading();
  }

  toggleAddRemove() {
    this.isAddingRemoving = true;
    this.#hideEachElement(this.percentTargets);
    this.#hideEachElement(this.exTargets);
    this.#toggleHiddenElement(this.newRateFormTarget);
    this.#toggleDisabledElement(this.addRemoveButtonTarget);
  }

  // Remove rate from DOM but don't commit change until form submitted
  softDelete(event) {
    event.preventDefault();
    const rateDiv = event.currentTarget.closest('.rate-div');
    this.softDeletedRates.push(rateDiv);
    // Remove benefit type from list of unique benefit types
    const idx = this.benefitTypes.indexOf(rateDiv.dataset.benefitType);
    this.benefitTypes.splice(idx, 1);
    // If new rate which hasn't been persisted, just remove from DOM
    if (this.newRateTargets.includes(rateDiv)) {
      rateDiv.remove();
    } else {
      // Otherwise hide and create hidden input on rate-div to mark for destroy by backend
      rateDiv.style.display = "none";
      const hiddenInput = document.createElement('input');
      hiddenInput.type = 'hidden';
      hiddenInput.name = 'marked_for_destroy[]';
      hiddenInput.value = rateDiv.dataset.rateId;
      hiddenInput.dataset.markedForDestroy = "true";
      rateDiv.appendChild(hiddenInput);
    }
  }

  // Frontend validation to prevent creation of non-unique benefit types
  softCreate(event) {
    const chapterValue = this.chapterInputTarget.value;
    const isDuplicate = this.benefitTypes.includes(chapterValue);
    if (isDuplicate) {
      event.preventDefault();
      this.chapterInputTarget.setCustomValidity("Chapter number must be unique");
      this.newRateFormTarget.reportValidity();
    } else {
      this.benefitTypes.push(chapterValue);
    }
  }

  clearValidity() {
    this.chapterInputTarget.setCustomValidity("");
  }

  // Prevent CRUD actions to Calculator Constants if rates form still in edit mode
  warn(event) {
    if (this.#isEditing()) {
      event.preventDefault();
      event.stopImmediatePropagation();
      this.#toggleHiddenElement(this.warningTarget);
    }
  }

  #isWarning() {
    return !this.warningTarget.classList.contains("hidden");
  }

  #toggleEditState() {
    this.formTarget.dataset.state = this.#isEditing() ? "viewing" : "editing";
  }

  #isEditing() {
    return this.formTarget.dataset.state === "editing";
  }

  #toggleHeading() {
    const { BLUE, GRAY } = this.constructor;
    const isBlue = this.headingTarget.style.backgroundColor === BLUE
    this.headingTarget.style.backgroundColor = isBlue? GRAY : BLUE;
  }

  #toggleDisabledElement(el) {
    el.disabled = !el.disabled;
  }

  #disableEachElement(els) {
    els.forEach(el => this.#toggleDisabledElement(el));
  }

  #toggleHiddenElement(el) {
    el.classList.toggle("hidden");
  }

  #hideEachElement(els) {
    els.forEach(el => this.#toggleHiddenElement(el));
  }
}

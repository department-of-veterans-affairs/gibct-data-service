import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "dialog", "select", "warning", "constantsList", "rateApplied", "ul", 
                     "confirm", "form", "applyButton" ];

  show(event) {
    event.preventDefault();
    event.stopImmediatePropagation()

    this.update();
    $(this.dialogTarget).modal("show");
    this.selectTarget.selectedIndex = 0;
  }

  update() {
    const selectedOption = this.selectTarget.selectedOptions[0];
    const { rate, constants } = selectedOption.dataset;
    const names = JSON.parse(constants);
    
    // Only enable modal if certain criteria met
    // If associated rate is 0%, disable modal
    if (rate === '0.0') {
      this.#showContent(0);
    // If zero constants affected, disable modal
    } else if (names.length === 0) {
      this.#showContent(1);
    // Otherwise, enable form submit
    } else {
      this.#showConstants(rate, names);
      this.#setFormUrl(selectedOption.value)
    }
  }

  #showContent(i) {
    this.#resetModal();
    this.warningTarget.children[i].hidden = false;
  }

  #showConstants(rate, names) {
    this.#showContent(2);
    this.confirmTarget.hidden = false;
    this.applyButtonTarget.disabled = false;
    this.rateAppliedTarget.innerText = rate;

    names.forEach(name => {
      const li = document.createElement("li");
      li.textContent = name;
      this.ulTarget.appendChild(li);
    });
  }

  // Default to modal disabled
  #resetModal() {
    this.applyButtonTarget.disabled = true;
    this.formTarget.action = "#";
    this.ulTarget.innerHTML = "";
    this.confirmTarget.hidden = true;
    this.warningTarget.children[0].hidden = true;
    this.warningTarget.children[1].hidden = true;
    this.warningTarget.children[2].hidden = true;
  }

  #setFormUrl(id) {
    this.formTarget.action = `/calculator_constants/apply_rate_adjustments/${id}`;
  }
}

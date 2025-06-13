import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "dialog", "select", "warning", "constantsList", "rateApplied", "ul", "confirm" ];

  connect() {
    this.updateRateApplied();
  }

  // Convert to input field on click
  enableEditing(event) {
    const [p, input] = event.currentTarget.children;
    p.style.display = "none";
    input.style.display = "block";
    input.focus();
  }

  // Convert back to static text on unfocus if unchanged
  disableEditing(event) {
    const [p, input] = event.currentTarget.children;
    const unchanged = input.value === p.textContent;
    if (unchanged) {
      p.textContent = input.value;
      p.style.display = "block";
      input.style.display = "none";
    }
  }

  enableSelect(event) {
    event.currentTarget.disabled = false;
  }

  disableSelect(event) {
    if (!event.currentTarget.value) {
      event.currentTarget.disabled = true;
    }
  }

  showModal(event) {
    event.preventDefault();
    event.stopImmediatePropagation()

    $(this.dialogTarget).modal("show");
  }

  updateRateApplied() {
    const selectedOption = this.selectTarget.selectedOptions[0];
    const { rate, constants } = selectedOption.dataset;
    const names = JSON.parse(constants);
    
    if (rate === 0.0) {
      this.#showContent(0);
    } else if (names.length === 0) {
      this.#showContent(1);
    } else {
      this.#showConstants(rate, names);
    }
  }

  #showContent(i) {
    this.#resetModal();
    this.warningTarget.children[i].hidden = false;
  }

  #showConstants(rate, names) {
    this.#showContent(2);
    this.confirmTarget.hidden = false;
    this.rateAppliedTarget.innerText = rate;

    names.forEach(name => {
      const li = document.createElement("li");
      li.textContent = name;
      this.ulTarget.appendChild(li);
    });
  }

  #resetModal() {
    this.ulTarget.innerHTML = "";
    this.confirmTarget.hidden = true;
    this.warningTarget.children[0].hidden = true;
    this.warningTarget.children[1].hidden = true;
    this.warningTarget.children[2].hidden = true;
  }
}

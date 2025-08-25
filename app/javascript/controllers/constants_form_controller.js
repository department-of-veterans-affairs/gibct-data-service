import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "input" ]

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

  formatInput(event) {
    const float = parseFloat(event.currentTarget.value);
    event.currentTarget.value = float.toFixed(2);
  }
}

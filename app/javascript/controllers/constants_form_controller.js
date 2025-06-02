import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "textCell", "select" ];

  connect() {
    // Constant name: enable edit on hover
    this.textCellTargets.forEach(cell => {
      const [p, input] = cell.children;

      // convert to input field on click
      cell.addEventListener("click", () => {
        p.style.display = "none";
        input.style.display = "block";
        input.focus();
      });

      // convert back to static text on unfocus if unchanged
      cell.addEventListener("focusout", () => {
        const unchanged = input.value === p.textContent;
        if (unchanged) {
          p.textContent = input.value;
          p.style.display = "block";
          input.style.display = "none";
        }
      });

    });

    // COLA select field: enable edit on hover
    this.selectTargets.forEach(select => {
      select.addEventListener("mouseenter", () => {
        select.disabled = false;
      });

      select.addEventListener("mouseleave", () => {
        if (select.value) {
          select.options[0].text = "none";
        } else {
          select.options[0].text = "";
          select.disabled = true;
        }
      });
    });
  }
}

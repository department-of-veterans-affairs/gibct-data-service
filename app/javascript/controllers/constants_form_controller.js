import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "select" ];

  connect() {
    // Enable editing when hovering over COLA type in constants table
    this.selectTargets.forEach(select => {
      select.addEventListener("mouseenter", (event) => {
        event.target.disabled = false;
      });

      select.addEventListener("mouseleave", (event) => {
        if (event.target.value) {
          event.target.options[0].text = "none";
        } else {
          event.target.options[0].text = "";
          event.target.disabled = true;
        }
      });
    });
  }
}

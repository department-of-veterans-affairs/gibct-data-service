import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "dialog", "form", "radioCurrent", "radioStart", "selectStart",
                     "selectEnd", "exportButton"];

  show(event) {
    event.preventDefault();
    event.stopImmediatePropagation();

    $(this.dialogTarget).modal("show");
    this.radioCurrentTarget.checked = true
    this.selectStartTarget.selectedIndex = 0;
    this.selectStartTarget.disabled = true;
    this.selectEndTarget.selectedIndex = this.selectEndTarget.options.length - 1;
    this.selectEndTarget.disabled = true;
  }

  toggleSelects(event) {
    this.exportButtonTarget.href = event.target.value;
    this.selectStartTarget.disabled = !this.selectStartTarget.disabled;
    this.selectEndTarget.disabled = !this.selectEndTarget.disabled;
  }

  updateStart() {
    const currentValue = parseInt(this.selectStartTarget.value);
    const startYear = parseInt(this.selectStartTarget.options[0].value);
    const endYear = parseInt(this.selectEndTarget.value);
    this.selectStartTarget.innerHTML = "";
    for(let year = startYear; year < endYear; year++) {
      const option = new Option(year, year);
      if (year === currentValue) {
        option.selected = true;
      }
      this.selectStartTarget.add(option);
    }
  }

  updateEnd() {
    const currentValue = parseInt(this.selectEndTarget.value);
    const startYear = parseInt(this.selectStartTarget.value) + 1;
    const idx = this.selectEndTarget.options.length - 1;
    const endYear = parseInt(this.selectEndTarget.options[idx].value);
    this.selectEndTarget.innerHTML = "";
    
    for(let year = startYear; year <= endYear; year++) {
      const text = (year === endYear ? "Present" : year);
      const option = new Option(text, year);
      if (year === currentValue) {
        option.selected = true;
      }
      this.selectEndTarget.add(option);
    }
  }
}

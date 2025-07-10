import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "dialog", "form", "radioCurrent", "radioHistory", "selectStart",
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
q
  toggleSelects(event) {
    this.#setExportPath(event.target);
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
    this.#setExportPath();
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
    this.#setExportPath();
  }

  download(event) {
    event.preventDefault();

    $(this.dialogTarget).modal("hide");

    setTimeout(() => {
      window.location = event.target.href;
    }, 300);
  }

  #setExportPath(target = this.radioHistoryTarget) {
    let path = target.value;
    
    if (target.id === "history") {
      const start = this.selectStartTarget.value;
      const end = this.selectEndTarget.value;
      path += `?start_year=${start}&end_year=${end}`;
    }
    this.exportButtonTarget.href = path;
  }
}

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "dialog" ]

  show() {
    $(this.dialogTarget).modal("show");
  }
}
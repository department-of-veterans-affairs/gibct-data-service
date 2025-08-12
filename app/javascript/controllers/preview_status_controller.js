import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { completed: Boolean, url: String };

  // TO-DO: When solid queue fully implemented, poll more frequently
  static POLLING_INTERVAL = 10_000;

  connect() {
    this.previewPoll = setInterval(() => this.#updatePreviewStatus(), POLLING_INTERVAL);
  }

  disconnect() {
    if (this.previewPoll) {
      clearInterval(this.previewPoll);
    }
  }

  async #updatePreviewStatus() {
    if (this.completedValue) {
      clearInterval(this.previewPoll);
      return;
    }

    try {
      const res = await fetch(this.urlValue, {
        headers: { Accept: "text/vnd.turbo-stream.html" },
        credentials: "same-origin",
        cache: "no-store"
      });
      if (!res.ok) {
        console.error(`Polling attempt failed: ${res.status} ${res.statusText}`);
        return;
      }
      const html = await res.text();
      Turbo.renderStreamMessage(html);
    } catch(err) {
      console.error(err);
    }
  }
}
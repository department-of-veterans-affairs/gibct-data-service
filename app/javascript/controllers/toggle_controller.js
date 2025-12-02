import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ 'feature' ];
  static values = {
    active: { type: Boolean, default: false }
  }

  enable() {
    this.activeValue = true;
  }

  disable() {
    this.activeValue = false;
  }

  activeValueChanged(_value, previous) {
    if (previous === undefined) return;

    this.featureTargets.forEach(feature => {
      const sideEffect = feature.dataset.sideEffect;
      if (!sideEffect) return;

      const isSet = feature.hasAttribute(sideEffect);
      feature.toggleAttribute(sideEffect, !isSet);
    });
  }
}
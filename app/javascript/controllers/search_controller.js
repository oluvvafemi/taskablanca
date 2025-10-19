import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "form", "results"];

  connect() {
    this.hideResults();
    this.boundClickOutside = this.clickOutside.bind(this);
    document.addEventListener("click", this.boundClickOutside);
  }

  disconnect() {
    document.removeEventListener("click", this.boundClickOutside);
  }

  queryChanged() {
    clearTimeout(this.timeout);
    const query = this.inputTarget.value.trim();

    this.timeout = setTimeout(() => {
      this.showResults();
      const once = () => {
        this.showResults();
        document.removeEventListener("turbo:frame-load", once);
      };
      document.addEventListener("turbo:frame-load", once);

      this.formTarget.requestSubmit();
    }, 300);
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults();
    }
  }

  hideResults() {
    this.resultsTarget.style.display = "none";
  }

  showResults() {
    this.resultsTarget.style.display = "block";
  }
}

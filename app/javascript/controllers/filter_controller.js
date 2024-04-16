import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filter"
export default class extends Controller {
  static targets = [ "filter" ]

  close() {
    this.filterTarget.classList.add("display-none-on-mobile")
    this.filterTarget.classList.remove("display-initial")
  }

  open() {
    this.filterTarget.classList.add("display-initial")
    this.filterTarget.classList.remove("display-none-on-mobile")
  }
}

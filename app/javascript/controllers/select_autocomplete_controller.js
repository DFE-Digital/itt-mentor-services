import { Controller } from "@hotwired/stimulus"
import accessibleAutocomplete from 'accessible-autocomplete'

// Connects to data-controller="select-autocomplete"
export default class extends Controller {
  static targets = [ "input" ]

  connect() {
    accessibleAutocomplete.enhanceSelectElement({
      selectElement: this.inputTarget
    })
  }
}

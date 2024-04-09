import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="claims-support-filter-search"
export default class extends Controller {
  static targets = [ "schoolInput", "schoolList", "providerInput", "providerList" ]

  connect() {
    if (this.schoolInputTarget.value !== "") {
      this.searchSchool()
    }

    if (this.providerInputTarget.value !== "") {
      this.searchProvider()
    }
  }

  searchSchool() {
    const schoolItems = this.schoolListTarget.children
    const searchValue = this.schoolInputTarget.value.toLowerCase()

    Array.from(schoolItems).forEach(function (item) {
      const inputField = item.querySelector("input")

      if (item.textContent.toLowerCase().indexOf(searchValue) > -1 ) {
        item.style.display = ""
      } else {
        item.style.display = "none"
        inputField.checked = false
      }
    })
  }

  searchProvider() {
    const providerItems = this.providerListTarget.children
    const searchValue = this.providerInputTarget.value.toLowerCase()

    Array.from(providerItems).forEach(function (item) {
      const inputField = item.querySelector("input")

      if (item.textContent.toLowerCase().indexOf(searchValue) > -1 ) {
        item.style.display = ""
      } else {
        item.style.display = "none"
        inputField.checked = false
      }
    })
  }
}

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="placements-filter-search"
export default class extends Controller {
  static targets = ["partnerSchoolInput", "partnerSchoolList", 
    "schoolInput", "schoolList", "subjectInput", "subjectList",
    "schoolTypeInput", "schoolTypeList"]

  connect() {
    if (this.partnerSchoolInputTarget.value !== "") {
      this.searchPartnerSchool()
    }

    if (this.schoolInputTarget.value !== "") {
      this.searchSchool()
    }

    if (this.subjectInputTarget.value !== "") {
      this.searchSubject()
    }

    if (this.schoolTypeInputTarget.value !== "") {
      this.searchSchoolType()
    }
  }

  searchSchool() {
    const schoolItems = this.schoolListTarget.children
    const searchValue = this.schoolInputTarget.value.toLowerCase()

    this.toggleItems(schoolItems, searchValue)
  }

  searchPartnerSchool(){
    const partnerSchoolItems = this.partnerSchoolListTarget.children
    const searchValue = this.partnerSchoolInputTarget.value.toLowerCase()

    this.toggleItems(partnerSchoolItems, searchValue)
  }

  searchSubject() {
    const subjectItems = this.subjectListTarget.children
    const searchValue = this.subjectInputTarget.value.toLowerCase()

    this.toggleItems(subjectItems, searchValue)
  }

  searchSchoolType() {
    const schoolTypeItems = this.schoolTypeListTarget.children
    const searchValue = this.schoolTypeInputTarget.value.toLowerCase()

    this.toggleItems(schoolTypeItems, searchValue)
  }

  toggleItems(items, searchValue){
    Array.from(items).forEach(function (item) {
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
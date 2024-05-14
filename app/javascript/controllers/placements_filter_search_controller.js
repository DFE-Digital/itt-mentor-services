import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="placements-filter-search"
export default class extends Controller {
  static targets = [
    "partnerSchoolInput",
    "partnerSchoolList",
    "schoolInput",
    "schoolList",
    "subjectInput",
    "subjectList",
    "establishmentGroupInput",
    "establishmentGroupList",
  ];

  connect() {
    if (this.partnerSchoolInputTarget.value !== "") {
      this.searchPartnerSchool();
    }

    if (this.schoolInputTarget.value !== "") {
      this.searchSchool();
    }

    if (this.subjectInputTarget.value !== "") {
      this.searchSubject();
    }

    if (this.establishmentGroupInputTarget.value !== "") {
      this.searchEstablishmentGroup();
    }
  }

  searchSchool() {
    const schoolItems = this.schoolListTarget.children;
    const searchValue = this.schoolInputTarget.value.toLowerCase();

    this.toggleItems(schoolItems, searchValue);
  }

  searchPartnerSchool() {
    const partnerSchoolItems = this.partnerSchoolListTarget.children;
    const searchValue = this.partnerSchoolInputTarget.value.toLowerCase();

    this.toggleItems(partnerSchoolItems, searchValue);
  }

  searchSubject() {
    const subjectItems = this.subjectListTarget.children;
    const searchValue = this.subjectInputTarget.value.toLowerCase();

    this.toggleItems(subjectItems, searchValue);
  }

  searchEstablishmentGroup() {
    const establishmentGroupItems = this.establishmentGroupListTarget.children;
    const searchValue = this.establishmentGroupInputTarget.value.toLowerCase();

    this.toggleItems(establishmentGroupItems, searchValue);
  }

  toggleItems(items, searchValue) {
    Array.from(items).forEach(function (item) {
      const inputField = item.querySelector("input");

      if (item.textContent.toLowerCase().indexOf(searchValue) > -1) {
        item.style.display = "";
      } else {
        item.style.display = "none";
        inputField.checked = false;
      }
    });
  }
}

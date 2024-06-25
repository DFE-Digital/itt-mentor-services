import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="filter-search"
export default class extends Controller {
  static targets = ["optionsList", "searchInput"];

  connect() {
    const list = this.element.querySelector(".govuk-checkboxes, .govuk-radios");

    if (!list) {
      throw new Error("Could not find checkboxes or radios to attach to");
    }

    list.dataset.filterSearchTarget = "optionsList";
    const searchInput = this.createSearchInput();
    list.before(searchInput);
  }

  createSearchInput() {
    const searchInput = document.createElement("input");
    searchInput.type = "search";
    searchInput.className = "govuk-input govuk-!-margin-bottom-1";
    searchInput.dataset.action = `input->${this.identifier}#search`;
    searchInput.dataset.filterSearchTarget = "searchInput";
    return searchInput;
  }

  search() {
    const optionItems = this.optionsListTarget.children;
    const searchValue = this.searchInputTarget.value.toLowerCase();
    this.toggleItems(optionItems, searchValue);
  }

  toggleItems(items, searchValue) {
    Array.from(items).forEach(function (item) {
      if (item.textContent.toLowerCase().indexOf(searchValue) > -1) {
        item.style.display = "";
      } else {
        item.style.display = "none";
      }
    });
  }
}

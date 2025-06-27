// app/javascript/controllers/async_filter_search_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["optionsList", "searchInput", "legend"];
  static instanceCounter = 0;
  static values = { endpoint: String, fieldname: String, labelname: String };

  constructor(...args) {
    super(...args);
    this.handleCheckboxChange = this.handleCheckboxChange.bind(this);
  }

  connect() {
    this.initializeState();
    this.setAsyncFilterSearchTargets();
    this.instanceId = this.constructor.instanceCounter++;

    const searchInput = this.createSearchInput();
    this.list.before(searchInput);

    this.debouncedSearch = this.debounce(this.search.bind(this), 150);

    this.initializeCheckedIds();
    this.attachCheckboxListeners();

    this.initialOptionsHtml = this.optionsListTarget.innerHTML;
  }

  initializeState() {
    this.checkedIds = new Set();
    this.list = this.element.querySelector(".govuk-checkboxes, .govuk-radios");
    this.legend = this.element.querySelector("legend");
  }

  setAsyncFilterSearchTargets() {
    this.list.dataset.asyncFilterSearchTarget = "optionsList";
    this.legend.dataset.asyncFilterSearchTarget = "legend";
  }

  initializeCheckedIds() {
    this.checkedIds.clear();
    this.list.querySelectorAll('input[type="checkbox"]:checked').forEach(cb => {
      this.checkedIds.add(cb.value);
    });
  }

  attachCheckboxListeners() {
    this.list.querySelectorAll('input[type="checkbox"]').forEach(cb => {
      cb.removeEventListener("change", this.handleCheckboxChange);
      cb.addEventListener("change", this.handleCheckboxChange);
    });
  }

  handleCheckboxChange(event) {
    if (event.target.type === "checkbox") {
      if (event.target.checked) {
        this.checkedIds.add(event.target.value);
      } else {
        this.checkedIds.delete(event.target.value);
      }
    }
  }

  createSearchInput() {
    const container = document.createElement("div");
    const inputId = `${this.identifier}-${this.instanceId}-input`;
    const labelText = `Filter ${this.legendTarget.innerText}`;

    const label = document.createElement("label");
    label.setAttribute("for", inputId);
    label.className = "govuk-label govuk-visually-hidden";
    label.textContent = labelText;

    const input = document.createElement("input");
    input.type = "search";
    input.id = inputId;
    input.className = "govuk-input govuk-!-margin-bottom-1";
    input.setAttribute("data-action", `input->${this.identifier}#debouncedSearch`);
    input.setAttribute("data-async-filter-search-target", "searchInput");

    container.appendChild(label);
    container.appendChild(input);

    return container;
  }

  async search() {
    const searchValue = this.searchInputTarget.value.trim();
    if (!searchValue) {
      this.optionsListTarget.innerHTML = this.initialOptionsHtml;
      this.attachCheckboxListeners();
      this.optionsListTarget.querySelectorAll('input[type="checkbox"]').forEach(cb => {
        cb.checked = this.checkedIds.has(cb.value);
      });
      return;
    }
    try {
      const response = await fetch(`${this.endpointValue}?q=${encodeURIComponent(searchValue)}&limit=25`);
      if (!response.ok) throw new Error("Network response was not ok");
      const schools = await response.json();
      this.renderOptions(schools);
    } catch (error) {
      console.error("Search failed:", error);
    }
  }

  renderOptions(schools) {
    const fragment = document.createDocumentFragment();
    const visibleIds = new Set();

    schools.forEach(school => {
      visibleIds.add(String(school.id));

      const div = document.createElement("div");
      div.className = "govuk-checkboxes__item";

      const input = document.createElement("input");
      input.id = `${this.labelnameValue}-${school.id}-field`;
      input.className = "govuk-checkboxes__input";
      input.type = "checkbox";
      input.value = school.id;
      input.name = this.fieldnameValue;
      if (this.checkedIds.has(String(school.id))) input.checked = true;
      input.addEventListener("change", this.handleCheckboxChange);

      const label = document.createElement("label");
      label.className = "govuk-label govuk-checkboxes__label";
      label.setAttribute("for", input.id);
      label.textContent = school.name;

      div.appendChild(input);
      div.appendChild(label);
      fragment.appendChild(div);
    });

    this.optionsListTarget.innerHTML = "";
    this.optionsListTarget.appendChild(fragment);

    [...this.checkedIds]
        .filter(id => !visibleIds.has(id))
        .forEach(id => {
          const hidden = document.createElement("input");
          hidden.type = "hidden";
          hidden.name = this.fieldnameValue;
          hidden.value = id;
          this.optionsListTarget.appendChild(hidden);
        });
  }

  debounce(fn, delay) {
    let timeout;
    return function (...args) {
      clearTimeout(timeout);
      timeout = setTimeout(() => fn.apply(this, args), delay);
    };
  }
}

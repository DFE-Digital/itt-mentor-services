import { Controller } from "@hotwired/stimulus"
import accessibleAutocomplete from 'accessible-autocomplete'
import debounce from "lodash.debounce";
import { request } from "../utils/request_helper";

// Connects to data-controller="autocomplete"
export default class extends Controller {
  static targets = [ "serverInput", "input" ]
  static values = {
    path: String,
    returnAttributes: Array,
  }

  connect() {
    const minLength = 2;

   accessibleAutocomplete({
     element: this.inputTarget,
     id: this.serverInputTarget.id,
     showNoOptionsFound: true,
     name: this.inputTarget.dataset.inputName,
     minLength,
     source: debounce(request(this.pathValue), 900),
     templates: {
       inputValue: this.inputValueTemplate.bind(this),
       suggestion: this.resultTemplate.bind(this),
     },
     onConfirm: this.onConfirm.bind(this),
     confirmOnBlur: false,
     autoselect: true,
   });

    // Hijack the original input to submit the selected value.
    this.serverInputTarget.id = `old-${this.serverInputTarget.id}`;
    this.serverInputTarget.type = "hidden";
  }

  private

  inputValueTemplate(result) {
    if (result) return result.name;
  }

  resultTemplate(result) {
    if (result) {
      var returnString = `${result.name}`
      var attributesString = ''
      this.returnAttributesValue.forEach(function(attribute) {
        attributesString = attributesString.concat(`${result[attribute]} `)
      });

      return returnString.concat(` (${attributesString.trim()})`)
    }
  }

  onConfirm(option) {
    this.serverInputTarget.value = option ? option.id : "";
  }
}

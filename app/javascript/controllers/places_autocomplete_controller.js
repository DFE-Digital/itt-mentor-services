import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="places-autocomplete"
export default class extends Controller {
  async connect(){
    await google.maps.importLibrary("places");

    const placesAutcompleteDiv = document.getElementById("places-autocomplete");
    const fieldName = placesAutcompleteDiv.dataset.fieldName;
    const inputId = fieldName.replace("_", "-") + "-field";
    const oldSearchInput = document.getElementById(inputId);

    const autocompleteElement = new google.maps.places.PlaceAutocompleteElement({
      componentRestrictions: { country: ['uk'] },
      name: "places_" + fieldName,
    });

    window.jamie = autocompleteElement;

    autocompleteElement.id = "places-" + inputId;

    oldSearchInput.parentNode.appendChild(autocompleteElement);
    // oldSearchInput.style.display = "none";

    autocompleteElement.addEventListener('gmp-placeselect', async ({ place }) => {
      await place.fetchFields({
        fields: ["formattedAddress"],
      });

      oldSearchInput.value = place.formattedAddress;
    });

    autocompleteElement.addEventListener('change', (e) => {
      console.log(document.getElementsByClassName("input-container"));
      console.log(e);
      oldSearchInput.value = e.innerText;
    });
  }
}

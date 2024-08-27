async function initMap() {
    // Request needed libraries.
    //@ts-ignore
    await google.maps.importLibrary("places");
  
    // Create the input HTML element, and append it.
    //@ts-ignore
    const placeAutocomplete = new google.maps.places.PlaceAutocompleteElement();
  
    //@ts-ignore
    document.getElementById("place-autocomplete-card").appendChild(placeAutocomplete);
    
    // Inject HTML UI.
    const selectedPlaceTitle = document.createElement("p");
  
    selectedPlaceTitle.textContent = "";
    document.getElementById("google-map").appendChild(selectedPlaceTitle);
  
    const selectedPlaceInfo = document.createElement("pre");
  
    selectedPlaceInfo.textContent = "";
    document.getElementById("google-map").appendChild(selectedPlaceInfo);
    // Add the gmp-placeselect listener, and display the results.
    //@ts-ignore
    placeAutocomplete.addEventListener("gmp-placeselect", async ({ place }) => {
      await place.fetchFields({
        fields: ["displayName", "formattedAddress", "location"],
      });
      selectedPlaceTitle.textContent = "Selected Place:";
      selectedPlaceInfo.textContent = JSON.stringify(
        place.toJSON(),
        /* replacer */ null,
        /* space */ 2,
      );
    });
  }
  
  initMap();
import initAutocomplete from "./autocomplete";

const providerTemplate = (result) => result && result.name;
const providerSuggestionTemplate = (result) =>
  result && `${result.name} (${result.town} ${result.postcode})`;
const onConfirm = (input) => (option) =>{
  (input.value = option ? option.urn : "");
}

function init() {
  const options = {
    path: `/api/school_suggestions`,
    template: {
      inputValue: providerTemplate,
      suggestion: providerSuggestionTemplate,
    },
    minLength: 2,
    inputName: "selection[urn]",
    onConfirm,
  };

  initAutocomplete(
    "school-autocomplete",
    "school-search-form-query-field",
    options,
  );
}

export default init;

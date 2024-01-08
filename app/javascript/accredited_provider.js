import initAutocomplete from "./autocomplete";

const providerTemplate = (result) => result && result.name;
const providerSuggestionTemplate = (result) =>
  result && `${result.name} (${result.provider_code})`;
const onConfirm = (input) => (option) =>
  (input.value = option ? option.id : "");

function init() {
  const options = {
    path: `/api/provider_suggestions`,
    template: {
      inputValue: providerTemplate,
      suggestion: providerSuggestionTemplate,
    },
    minLength: 2,
    inputName: "provider[search_code]",
    onConfirm,
  };

  initAutocomplete(
    "accredited-provider-autocomplete",
    "accredited-provider-search-form-query-field",
    options,
  );
}

export default init;

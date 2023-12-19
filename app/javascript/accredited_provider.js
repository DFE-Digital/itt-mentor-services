import initAutocomplete from "./autocomplete";

const providerTemplate = (result) => result && result.name;
const providerSuggestionTemplate = (result) =>
  result && `${result.name} (${result.code})`;
const onConfirm = (input) => (option) =>
  (input.value = option ? option.code : "");

function init() {
  const options = {
    path: `/support/provider_suggestions`,
    template: {
      inputValue: providerTemplate,
      suggestion: providerSuggestionTemplate,
    },
    minLength: 2,
    inputName: "accredited_provider_id",
    onConfirm,
  };

  initAutocomplete(
    "accredited-provider-autocomplete",
    "accredited-provider-search-form-query-field",
    options,
  );
}

export default init;

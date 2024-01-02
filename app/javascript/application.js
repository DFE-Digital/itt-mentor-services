import { initAll } from "govuk-frontend";
import autocompleteSetup from "./autocomplete";
import accreditedProviderAutocompleteSetup from "./accredited_provider";
import schoolAutocompleteSetup from "./school";

initAll();
autocompleteSetup();
accreditedProviderAutocompleteSetup();
schoolAutocompleteSetup();

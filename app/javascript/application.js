import { initAll } from "govuk-frontend";
import autocompleteSetup from "./autocomplete";
import providerAutocompleteSetup from "./provider";
import schoolAutocompleteSetup from "./school";

initAll();
autocompleteSetup();
providerAutocompleteSetup();
schoolAutocompleteSetup();
import "./controllers"

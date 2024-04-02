class Api::Placements::ProviderSuggestionsController < Api::ProviderSuggestionsController
  private

  def model
    Placements::Provider
  end
end

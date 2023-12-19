class Placements::Support::ProviderSuggestionsController < Placements::Support::ApplicationController
  def index
    accredited_providers = AccreditedProviderApi.call
    filtered_providers = filter_providers(accredited_providers, query_params)
    providers =
      filtered_providers.map { |provider| formatted_provider(provider) }
    render json: providers
  end

  private

  def query_params
    params.require(:query)
  end

  def filter_providers(providers, query)
    return providers if query.blank?

    downcase_query = query.downcase
    providers.select do |provider|
      [
        provider.dig("attributes", "name"),
        provider.dig("attributes", "postcode"),
        provider.dig("attributes", "urn"),
        provider.dig("attributes", "ukprn"),
      ].any? { |attribute| attribute&.downcase&.include?(downcase_query) }
    end
  end

  def formatted_provider(provider)
    {
      id: provider.fetch("id"),
      name: provider.dig("attributes", "name"),
      code: provider.dig("attributes", "code"),
    }
  end
end

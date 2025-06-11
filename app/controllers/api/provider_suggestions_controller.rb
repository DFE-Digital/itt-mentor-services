class Api::ProviderSuggestionsController < ApplicationController
  def index
    render json: providers_to_render.search_name_urn_ukprn_postcode(query_params)
                         .select(:id, :name, :postcode, :code)
                         .limit(50)
  end

  private

  def query_params
    params.require(:query)&.downcase
  end

  def providers_to_render
    current_service == :claims ? claims_providers_scope : placements_providers_scope
  end

  def claims_providers_scope
    @claims_providers_scope ||= Provider.excluding_niot_providers
  end

  def placements_providers_scope
    @placements_providers_scope ||= Provider
  end
end

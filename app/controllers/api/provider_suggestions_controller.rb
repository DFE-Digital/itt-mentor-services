class Api::ProviderSuggestionsController < ApplicationController
  def index
    render json: model.search_name_urn_ukprn_postcode(query_params)
  end

  private

  def query_params
    params.require(:query)&.downcase
  end

  def model
    Provider
  end
end

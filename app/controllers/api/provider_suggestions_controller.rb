class Api::ProviderSuggestionsController < ApplicationController
  def index
    render json: Provider.search_name_urn_ukprn_postcode(query_params)
                         .select(:id, :name, :code)
                         .limit(50)
  end

  private

  def query_params
    params.require(:query)&.downcase
  end
end

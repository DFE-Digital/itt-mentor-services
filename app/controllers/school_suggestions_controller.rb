class SchoolSuggestionsController < ApplicationController
  def index
    render json: GiasSchool.search_name_urn_postcode(query_params)
  end

  private

  def query_params
    params.require(:query)&.downcase
  end
end

class Api::SchoolSuggestionsController < ApplicationController
  def index
    schools = model.search_name_urn_postcode(query_params)
    render json: schools
  end

  private

  def query_params
    params.require(:query)&.downcase
  end

  def model
    School
  end
end

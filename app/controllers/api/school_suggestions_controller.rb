class Api::SchoolSuggestionsController < ApplicationController
  def index
    render json: School.search_name_urn_postcode(query_params)
                       .select(:id, :name, :town, :postcode)
                       .limit(50)
  end

  private

  def query_params
    params.require(:query)&.downcase
  end
end

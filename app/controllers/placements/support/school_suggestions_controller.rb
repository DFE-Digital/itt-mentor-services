class Placements::Support::SchoolSuggestionsController < Placements::Support::ApplicationController
  def index
    schools = GiasSchool.search_name_urn_postcode(query_params)

    render json: schools
  end

  private

  def query_params
    params.require(:query)&.downcase
  end
end

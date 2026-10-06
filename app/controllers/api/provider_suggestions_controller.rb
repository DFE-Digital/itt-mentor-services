class Api::ProviderSuggestionsController < ApplicationController
  def index
    render json: providers_to_render.search_name_urn_ukprn_postcode(query_params)
                         .select(:id, :name, :postcode, :code)
                         .limit(50)
  end

  private

  def academic_year
    @academic_year ||= params[:academic_year_id].present? ? AcademicYear.find(params[:academic_year_id]) : AcademicYear.current
  end

  def query_params
    params.require(:query)&.downcase
  end

  def providers_to_render
    current_service == :claims ? claims_providers_scope : placements_providers_scope
  end

  def claims_providers_scope
    @claims_providers_scope ||= Provider.excluding_niot_providers.eligible_for_academic_year(academic_year)
  end

  def placements_providers_scope
    @placements_providers_scope ||= Provider
  end
end

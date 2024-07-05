class Placements::Support::OrganisationsController < Placements::ApplicationController
  def index
    @pagy, @organisations = pagy(organisations)
    @filters = filters_param
  end

  private

  def organisations
    @organisations ||= Placements::OrganisationFinder.call(filters: filters_param, search_term: search_param)
  end

  def filters_param
    params.fetch(:filters, []).compact.reject(&:blank?)
  end

  def search_param
    params.fetch(:name_or_postcode, "")
  end
end

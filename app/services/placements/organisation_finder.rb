class Placements::OrganisationFinder
  include ServicePattern

  def initialize(filters: [], search_term: "")
    @filters = filters
    @search_term = search_term
  end

  def call
    organisations.includes([:searchable]).where(organisation_type: organisation_types)
  end

  private

  attr_reader :filters, :search_term

  def organisation_types
    filters.presence || (Provider.provider_types.keys << "school")
  end

  def organisations
    @organisations ||= if search_term.blank?
                         PgSearch::Document.order(:content)
                       else
                         PgSearch.multisearch(search_term)
                       end
  end
end

module Placements::Support::OrganisationsHelper
  def no_results(search = "", filters = [])
    if search.blank? && filters.blank?
      I18n.t("placements.support.organisations.index.no_organisations")
    elsif search.blank?
      I18n.t("no_results_with_filter")
    elsif filters.blank?
      I18n.t("no_results", for: search)
    else
      I18n.t("no_results_with_filter_and_search", for: search)
    end
  end

  def organisation_url(organisation)
    case organisation.searchable_type
    when "School"
      placements_support_school_path(organisation.searchable)
    when "Provider"
      placements_support_provider_path(organisation.searchable)
    end
  end

  def filter_options
    (Provider.provider_types.keys << "school").sort
  end
end

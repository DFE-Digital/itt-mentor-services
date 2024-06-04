class Placements::OrganisationsController < Placements::ApplicationController
  before_action :redirect_to_organisation_if_only_one, only: :index
  def index; end

  private

  def redirect_to_organisation_if_only_one
    set_memberships

    if @memberships.one?
      set_session_provider
      redirect_to placements_organisation_path(organisation)
    end
  end

  def set_memberships
    @memberships = current_user.user_memberships.filter(&:placements_service).sort_by(&:name)
  end

  def organisation
    @organisation ||= current_user.user_memberships.first.organisation
  end

  def set_session_provider
    session[:placements_provider_id] = organisation.id if organisation.is_a?(Provider)
  end
end

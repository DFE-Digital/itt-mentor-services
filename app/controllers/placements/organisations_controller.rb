class Placements::OrganisationsController < Placements::ApplicationController
  before_action :auto_redirect_if_only_one, only: :index
  skip_before_action :set_current_organisation

  def index
    scope = policy_scope(memberships)
    @memberships = scope.filter(&:placements_service).sort_by(&:name)
  end

  def show
    membership = memberships.find(params[:id])
    load_organisation(membership)
  end

  private

  def auto_redirect_if_only_one
    load_organisation(memberships.first) if memberships.one?
  end

  def memberships
    current_user.user_memberships.includes(:organisation)
  end

  def load_organisation(membership)
    organisation = membership.organisation

    set_session_current_organisation(organisation)
    redirect_to landing_page_path(organisation)
  end

  def set_session_current_organisation(organisation)
    session["current_organisation"] = { "id" => organisation.id, "type" => organisation.class.name }
  end

  def landing_page_path(organisation)
    if organisation.is_a?(School)
      placements_school_placements_path(organisation)
    else # Provider
      placements_placements_path
    end
  end
end

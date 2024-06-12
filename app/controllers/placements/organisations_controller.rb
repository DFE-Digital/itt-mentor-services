class Placements::OrganisationsController < Placements::ApplicationController
  before_action :auto_redirect_if_only_one, only: :index

  def index
    @memberships = memberships.filter(&:placements_service).sort_by(&:name)
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

    set_current_provider(organisation)
    redirect_to landing_page_path(organisation)
  end

  def set_current_provider(organisation)
    if organisation.is_a?(Provider)
      session[:placements_provider_id] = organisation.id
    else
      session.delete(:placements_provider_id)
    end
  end

  def landing_page_path(organisation)
    case organisation
    when School
      placements_school_placements_path(organisation)
    when Provider
      # placements_placements_path
      placements_provider_path(organisation)
    end
  end
end

class Placements::OrganisationsController < Placements::ApplicationController
  before_action :auto_redirect_if_only_one, only: :index

  def index
    scope = policy_scope(memberships)
    @memberships = scope.filter(&:placements_service).sort_by(&:name)
  end

  def show
    redirect_to landing_page_path(organisation)
  end

  private

  def auto_redirect_if_only_one
    redirect_to landing_page_path(memberships.first.organisation) if memberships.one?
  end

  def memberships
    current_user.user_memberships.includes(:organisation)
  end

  def organisation
    @organisation ||= if params.fetch(:type) == "School"
                        policy_scope(Placements::School).find(params.require(:id))
                      else
                        policy_scope(Placements::Provider).find(params.require(:id))
                      end
  end

  def landing_page_path(organisation)
    if organisation.is_a?(School)
      if organisation.expression_of_interest_completed?
        placements_school_placements_path(organisation)
      else
        new_add_hosting_interest_placements_school_hosting_interests_path(organisation)
      end
    elsif !Flipper.enabled?(:provider_hide_find_placements, organisation) # Provider
      placements_provider_find_index_path(organisation)
    else
      placements_provider_placements_path(organisation)
    end
  end
end

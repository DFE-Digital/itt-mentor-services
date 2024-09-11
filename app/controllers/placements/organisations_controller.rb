class Placements::OrganisationsController < Placements::ApplicationController
  before_action :auto_redirect_if_only_one, only: :index
  skip_before_action :ensure_current_organisation_present

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
    current_user.current_organisation = case organisation
                                when School
                                  organisation.becomes(Placements::School)
                                when Provider
                                  organisation.becomes(Placements::Provider)
                                end

    session["current_organisation"] = { "id" => organisation.id, "type" => organisation.class.name }

    redirect_to after_sign_in_path
  end
end

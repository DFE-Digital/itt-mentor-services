class Placements::OrganisationsController < ApplicationController
  before_action :redirect_to_organisation_if_only_one, only: :index
  def index; end

  private

  def redirect_to_organisation_if_only_one
    set_memberships

    if @memberships.one?
      redirect_to placements_organisation_path(organisation)
    end
  end

  def set_memberships
    @memberships = current_user.memberships.filter(&:placements_service).sort_by(&:name)
  end

  def organisation
    @organisation ||= current_user.memberships.first.organisation
  end
end

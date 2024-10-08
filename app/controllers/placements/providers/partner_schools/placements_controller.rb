class Placements::Providers::PartnerSchools::PlacementsController < Placements::ApplicationController
  before_action :set_provider, only: %i[index show]
  before_action :set_partner_school, only: %i[index show]

  def index
    @placements_assigned_to_provider = placements.where(provider: @provider).decorate
    @other_placements = placements.where.not(provider: @provider)
      .or(placements.where(provider: nil)).decorate
  end

  def show
    @placement = placements.find(params.require(:id)).decorate
    @partner_school = @placement.school
  end

  private

  def set_partner_school
    @partner_school = @provider.partner_schools.find(params.require(:partner_school_id)).becomes(Placements::School)
  end

  def placements
    policy_scope(@partner_school.placements, policy_scope_class: Placements::Provider::PlacementPolicy::Scope)
  end
end

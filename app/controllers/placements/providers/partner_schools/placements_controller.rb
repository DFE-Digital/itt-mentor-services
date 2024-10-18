class Placements::Providers::PartnerSchools::PlacementsController < Placements::ApplicationController
  skip_after_action :verify_policy_scoped, only: %i[index]
  before_action :set_provider, only: %i[index show]
  before_action :set_partner_school, only: %i[index show]

  def index
    @placements_assigned_to_provider = placements_scope.where(provider: @provider).decorate
    @other_placements = placements_scope.where.not(provider: @provider)
      .or(placements_scope.where(provider: nil)).decorate
  end

  def show
    @placement = placements_scope.find(params.require(:id)).decorate
    @partner_school = @placement.school
  end

  private

  def set_partner_school
    @partner_school = @provider.partner_schools.find(params.require(:partner_school_id)).becomes(Placements::School)
  end

  def placements_scope
    @partner_school.placements
  end
end

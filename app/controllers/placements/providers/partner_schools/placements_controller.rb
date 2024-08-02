class Placements::Providers::PartnerSchools::PlacementsController < ApplicationController
  before_action :set_provider, only: %i[index show]
  before_action :set_partner_school, only: %i[index show]

  def index
    placements_assigned_to_provider = @partner_school.placements.where(provider_id: @provider.id)
    other_placements = @partner_school.placements.where.not(id: placements_assigned_to_provider.ids)
    @placements_assigned_to_provider = placements_assigned_to_provider.decorate
    @other_placements = other_placements.decorate
  end

  def show
    @placement = @partner_school.placements.find(params.require(:id)).decorate
    @partner_school = @placement.school
  end

  private

  def set_partner_school
    @partner_school = @provider.partner_schools.find(params.require(:partner_school_id)).becomes(Placements::School)
  end

  def set_provider
    provider_id = params.fetch(:provider_id)
    @provider = current_user.providers.find(provider_id)
  end
end

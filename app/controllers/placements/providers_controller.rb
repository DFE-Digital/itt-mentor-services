class Placements::ProvidersController < ApplicationController
  before_action :set_providers

  def show
    @provider = @providers.find(params.require(:id))&.decorate
  end

  private

  def set_providers
    @providers = current_user.providers.where(placements_service: true)
  end
end

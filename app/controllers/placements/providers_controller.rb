class Placements::ProvidersController < Placements::ApplicationController
  def show
    @provider = providers.find(params.require(:id)).decorate
  end

  private

  def providers
    current_user.support_user? ? Placements::Provider.all : current_user.providers
  end
end

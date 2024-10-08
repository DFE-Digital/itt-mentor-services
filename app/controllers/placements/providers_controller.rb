class Placements::ProvidersController < Placements::ApplicationController
  def show
    @provider = providers.find(params.require(:id)).decorate
  end

  private

  def providers
    policy_scope(Placements::Provider)
  end
end
